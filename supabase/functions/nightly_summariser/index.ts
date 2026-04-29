// =============================================================================
// nightly_summariser — Supabase Edge Function (Deno)
// -----------------------------------------------------------------------------
// Runs nightly via pg_cron. For every user who has had any activity in the
// last 24 hours, it computes numeric rollups over the last 7 days and writes
// a fresh row to `ai_summaries`. The `summary_text` it produces is generated
// LOCALLY via a deterministic template — no OpenAI call is made here.
//
// Why local generation?
//   * Cost: the summariser runs nightly for every active user.
//   * Privacy: the output of this function IS the context that the coach
//     function is permitted to send upstream, so it must be strictly derived
//     from numeric aggregates — no free-text leakage.
//   * Determinism: the same inputs produce the same summary, which is easier
//     to reason about in audits and tests.
//
// Auth: this function is invoked server-side (via pg_cron → pg_net) with the
// SERVICE ROLE key. It therefore bypasses RLS intentionally so it can iterate
// over all users. It must NEVER be exposed to client callers. Supabase marks
// scheduled functions as such; in addition we require the caller to present
// the service role key as a Bearer token.
// =============================================================================

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

// -----------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------
type Zone = "self" | "purpose" | "loved_ones";

interface CheckinRow {
    user_id: string;
    mood: number;
    stress: number;
    energy: number;
    sleep: number;
    habit_completion: boolean;
    focus_zone: Zone;
    local_date: string; // ISO date
}

interface HabitLogRow {
    user_id: string;
    completed: boolean;
    local_date: string;
}

interface DailyPlanRow {
    user_id: string;
    local_date: string;
    day_type: "recovery" | "gentle" | "momentum" | "balanced";
}

interface UserAggregates {
    days_logged: number;
    avg_mood: number | null;
    avg_stress: number | null;
    avg_energy: number | null;
    avg_sleep: number | null;
    low_energy_days: number;        // energy <= 2
    high_stress_days: number;       // stress >= 4
    habit_days_checkin: number;     // check_ins.habit_completion true
    habit_logs_completed: number;   // habit_logs.completed true
    habit_logs_total: number;
    zone_counts: Record<Zone, number>;
    strongest_zone: Zone | null;
    neglected_zone: Zone | null;
    mood_trend: "improving" | "declining" | "flat";
    plans_count: number;
    window_start: string;
    window_end: string;
}

interface SummaryUpsertRow {
    user_id: string;
    window_start: string;
    window_end: string;
    summary_text: string;
    aggregates: Record<string, unknown>;
}

// -----------------------------------------------------------------------------
// Config
// -----------------------------------------------------------------------------
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const WINDOW_DAYS = 7;
const ACTIVITY_LOOKBACK_HOURS = 24;

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
function jsonResponse(status: number, body: unknown): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { "Content-Type": "application/json" },
    });
}

function toIsoDate(d: Date): string {
    return d.toISOString().slice(0, 10);
}

function round2(n: number): number {
    return Math.round(n * 100) / 100;
}

function avg(nums: number[]): number | null {
    if (nums.length === 0) return null;
    const total = nums.reduce((a, b) => a + b, 0);
    return round2(total / nums.length);
}

// Linear-regression-ish slope; positive = improving, negative = declining.
// We use a simple first-half vs second-half comparison, which is stable at
// the very small n (<= 7) we expect here.
function moodTrend(rows: CheckinRow[]): "improving" | "declining" | "flat" {
    if (rows.length < 3) return "flat";
    const sorted = [...rows].sort((a, b) => a.local_date.localeCompare(b.local_date));
    const mid = Math.floor(sorted.length / 2);
    const firstHalf = sorted.slice(0, mid);
    const secondHalf = sorted.slice(sorted.length - mid);
    const f = avg(firstHalf.map((r) => r.mood)) ?? 0;
    const s = avg(secondHalf.map((r) => r.mood)) ?? 0;
    const delta = s - f;
    if (delta >= 0.4) return "improving";
    if (delta <= -0.4) return "declining";
    return "flat";
}

function zoneLabel(z: Zone): string {
    return z === "loved_ones" ? "Loved Ones" : z === "self" ? "Self" : "Purpose";
}

function computeAggregates(
    userId: string,
    windowStart: string,
    windowEnd: string,
    checkins: CheckinRow[],
    habitLogs: HabitLogRow[],
    plans: DailyPlanRow[],
): UserAggregates {
    const zoneCounts: Record<Zone, number> = { self: 0, purpose: 0, loved_ones: 0 };
    let lowEnergyDays = 0;
    let highStressDays = 0;
    let habitDaysCheckin = 0;

    for (const c of checkins) {
        zoneCounts[c.focus_zone] += 1;
        if (c.energy <= 2) lowEnergyDays += 1;
        if (c.stress >= 4) highStressDays += 1;
        if (c.habit_completion) habitDaysCheckin += 1;
    }

    // strongest = max count, neglected = zero-count zone (if any)
    const zones: Zone[] = ["self", "purpose", "loved_ones"];
    let strongest: Zone | null = null;
    let strongestCount = -1;
    for (const z of zones) {
        if (zoneCounts[z] > strongestCount) {
            strongestCount = zoneCounts[z];
            strongest = z;
        }
    }
    if (strongestCount <= 0) strongest = null;

    const neglectedCandidates = zones.filter((z) => zoneCounts[z] === 0);
    const neglected: Zone | null = neglectedCandidates.length > 0 ? neglectedCandidates[0] : null;

    const habitLogsCompleted = habitLogs.filter((h) => h.completed).length;

    const _ = userId; // userId isn't needed inside aggregates (set by caller).
    void _;

    return {
        days_logged: checkins.length,
        avg_mood: avg(checkins.map((c) => c.mood)),
        avg_stress: avg(checkins.map((c) => c.stress)),
        avg_energy: avg(checkins.map((c) => c.energy)),
        avg_sleep: avg(checkins.map((c) => c.sleep)),
        low_energy_days: lowEnergyDays,
        high_stress_days: highStressDays,
        habit_days_checkin: habitDaysCheckin,
        habit_logs_completed: habitLogsCompleted,
        habit_logs_total: habitLogs.length,
        zone_counts: zoneCounts,
        strongest_zone: strongest,
        neglected_zone: neglected,
        mood_trend: moodTrend(checkins),
        plans_count: plans.length,
        window_start: windowStart,
        window_end: windowEnd,
    };
}

function renderSummaryText(agg: UserAggregates): string {
    // Deterministic template. Every phrase is derived from numeric rollups.
    if (agg.days_logged === 0) {
        return "User has not logged a check-in in the last 7 days.";
    }

    const parts: string[] = [];

    if (agg.low_energy_days > 0) {
        parts.push(`User has had ${agg.low_energy_days} low-energy day${agg.low_energy_days === 1 ? "" : "s"} this week`);
    } else {
        parts.push("Energy has been steady this week");
    }

    if (agg.high_stress_days > 0) {
        parts.push(`with ${agg.high_stress_days} high-stress day${agg.high_stress_days === 1 ? "" : "s"}`);
    }

    if (agg.strongest_zone) {
        parts.push(
            `strongest zone is ${zoneLabel(agg.strongest_zone)} (${agg.zone_counts[agg.strongest_zone]} focus days)`,
        );
    }

    if (agg.neglected_zone) {
        parts.push(`neglected zone is ${zoneLabel(agg.neglected_zone)} (0 focus days)`);
    }

    parts.push(`habits completed ${agg.habit_days_checkin} of ${agg.days_logged} days`);
    parts.push(`mood trend: ${agg.mood_trend}`);

    return parts.join(", ") + ".";
}

// -----------------------------------------------------------------------------
// Data access (service role — bypasses RLS intentionally)
// -----------------------------------------------------------------------------
async function findActiveUserIds(sb: SupabaseClient, sinceIso: string): Promise<string[]> {
    // A user is "active" if they created any row in the last
    // ACTIVITY_LOOKBACK_HOURS in any of: check_ins, habit_logs, coach_messages.
    const ids = new Set<string>();

    const { data: c, error: ce } = await sb
        .from("check_ins")
        .select("user_id")
        .gte("created_at", sinceIso);
    if (ce) throw new Error(`active users check_ins: ${ce.message}`);
    for (const r of c ?? []) ids.add((r as { user_id: string }).user_id);

    const { data: h, error: he } = await sb
        .from("habit_logs")
        .select("user_id")
        .gte("created_at", sinceIso);
    if (he) throw new Error(`active users habit_logs: ${he.message}`);
    for (const r of h ?? []) ids.add((r as { user_id: string }).user_id);

    const { data: m, error: me } = await sb
        .from("coach_messages")
        .select("user_id")
        .gte("created_at", sinceIso);
    if (me) throw new Error(`active users coach_messages: ${me.message}`);
    for (const r of m ?? []) ids.add((r as { user_id: string }).user_id);

    return [...ids];
}

async function loadUserCheckins(
    sb: SupabaseClient,
    userId: string,
    windowStart: string,
): Promise<CheckinRow[]> {
    const { data, error } = await sb
        .from("check_ins")
        .select("user_id, mood, stress, energy, sleep, habit_completion, focus_zone, local_date")
        .eq("user_id", userId)
        .gte("local_date", windowStart);
    if (error) throw new Error(`check_ins load: ${error.message}`);
    return (data ?? []) as CheckinRow[];
}

async function loadUserHabitLogs(
    sb: SupabaseClient,
    userId: string,
    windowStart: string,
): Promise<HabitLogRow[]> {
    const { data, error } = await sb
        .from("habit_logs")
        .select("user_id, completed, local_date")
        .eq("user_id", userId)
        .gte("local_date", windowStart);
    if (error) throw new Error(`habit_logs load: ${error.message}`);
    return (data ?? []) as HabitLogRow[];
}

async function loadUserPlans(
    sb: SupabaseClient,
    userId: string,
    windowStart: string,
): Promise<DailyPlanRow[]> {
    const { data, error } = await sb
        .from("daily_plans")
        .select("user_id, local_date, day_type")
        .eq("user_id", userId)
        .gte("local_date", windowStart);
    if (error) throw new Error(`daily_plans load: ${error.message}`);
    return (data ?? []) as DailyPlanRow[];
}

async function upsertSummary(sb: SupabaseClient, row: SummaryUpsertRow): Promise<void> {
    // Idempotent on (user_id, window_end). See ai_summaries_unique_window.
    const { error } = await sb
        .from("ai_summaries")
        .upsert(row, { onConflict: "user_id,window_end" });
    if (error) throw new Error(`ai_summaries upsert: ${error.message}`);
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------
Deno.serve(async (req: Request): Promise<Response> => {
    // Accept both GET (manual trigger) and POST (pg_cron + pg_net default).
    if (!["GET", "POST"].includes(req.method)) {
        return jsonResponse(405, { error: "method_not_allowed" });
    }

    if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
        return jsonResponse(500, { error: "supabase_env_missing" });
    }

    // Require the service role key as a Bearer. pg_net is configured to pass
    // this header (see README). Reject otherwise.
    const authHeader =
        req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";
    if (!authHeader.toLowerCase().startsWith("bearer ")) {
        return jsonResponse(401, { error: "missing_bearer_token" });
    }
    const token = authHeader.slice(7).trim();
    if (token !== SERVICE_ROLE_KEY) {
        return jsonResponse(401, { error: "forbidden" });
    }

    const sb: SupabaseClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
        auth: { persistSession: false, autoRefreshToken: false },
    });

    const now = new Date();
    const windowEnd = toIsoDate(now);
    const windowStartDate = new Date(now);
    windowStartDate.setUTCDate(windowStartDate.getUTCDate() - (WINDOW_DAYS - 1));
    const windowStart = toIsoDate(windowStartDate);

    const activitySince = new Date(now);
    activitySince.setUTCHours(activitySince.getUTCHours() - ACTIVITY_LOOKBACK_HOURS);

    let userIds: string[];
    try {
        userIds = await findActiveUserIds(sb, activitySince.toISOString());
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return jsonResponse(500, { error: "active_users_failed", detail: msg });
    }

    const results: Array<{ user_id: string; ok: boolean; error?: string }> = [];

    for (const userId of userIds) {
        try {
            const [checkins, habitLogs, plans] = await Promise.all([
                loadUserCheckins(sb, userId, windowStart),
                loadUserHabitLogs(sb, userId, windowStart),
                loadUserPlans(sb, userId, windowStart),
            ]);

            const aggregates = computeAggregates(
                userId,
                windowStart,
                windowEnd,
                checkins,
                habitLogs,
                plans,
            );

            const summaryText = renderSummaryText(aggregates);

            await upsertSummary(sb, {
                user_id: userId,
                window_start: windowStart,
                window_end: windowEnd,
                summary_text: summaryText,
                aggregates: aggregates as unknown as Record<string, unknown>,
            });

            results.push({ user_id: userId, ok: true });
        } catch (e) {
            const msg = e instanceof Error ? e.message : String(e);
            results.push({ user_id: userId, ok: false, error: msg });
        }
    }

    return jsonResponse(200, {
        window_start: windowStart,
        window_end: windowEnd,
        users_processed: results.length,
        failures: results.filter((r) => !r.ok).length,
        results,
    });
});
