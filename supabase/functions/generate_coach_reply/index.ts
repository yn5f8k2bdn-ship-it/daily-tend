// =============================================================================
// generate_coach_reply — Supabase Edge Function (Deno)
// -----------------------------------------------------------------------------
// Generates a coaching reply for the authenticated user by calling OpenAI's
// Responses API with a tightly-scoped, privacy-scrubbed context.
//
// ─── PRIVACY ASSERTION ──────────────────────────────────────────────────────
// What IS sent to OpenAI:
//   * The user's `goal` (free text they explicitly set in onboarding).
//   * The user's `coaching_tone` preference.
//   * The user's `preferred_zone` preference.
//   * Numeric aggregates from `v_last_7_checkins` and `v_zone_balance_7d`
//     (averages and counts only — no free-text content).
//   * The `summary_text` field from the latest `ai_summaries` row. This field
//     is produced by `nightly_summariser` from a deterministic template over
//     numeric aggregates; it does NOT contain raw reflection notes.
//   * The CURRENT user turn (the single `user_message` from the request body).
//
// What is NEVER sent to OpenAI:
//   * Raw `reflection_note` content from `check_ins`.
//   * Prior rows from `coach_messages` (the user-visible chat history).
//   * Any auth identifiers, emails, display_name, or Supabase row ids.
//   * Raw habit names or log content.
//
// Rate limiting:
//   * Not implemented in V1. Add a token-bucket or Supabase rate-limit rule
//     (e.g. via a per-user counter table or PostgREST rule) before GA to
//     prevent runaway OpenAI spend. A pragmatic floor: N replies per user per
//     hour gated in this function, plus a hard daily cap.
// ─────────────────────────────────────────────────────────────────────────────

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

// -----------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------
type Zone = "self" | "purpose" | "loved_ones";
type CoachingTone = "calm" | "practical" | "tough_love" | "reflective";

interface RequestBody {
    user_message: string;
}

interface ProfileRow {
    user_id: string;
    goal: string | null;
    coaching_tone: CoachingTone;
    preferred_zone: Zone | null;
}

interface SummaryRow {
    summary_text: string;
    aggregates: Record<string, unknown>;
    window_start: string;
    window_end: string;
}

interface CheckinAggregates {
    days_logged: number;
    avg_mood: number | null;
    avg_stress: number | null;
    avg_energy: number | null;
    avg_sleep: number | null;
    habit_days: number;
}

interface ZoneBalance {
    self_days: number;
    purpose_days: number;
    loved_ones_days: number;
}

interface CoachReply {
    reply: string;
    actions: string[];
}

interface OpenAIResponsesPayload {
    model: string;
    input: Array<{
        role: "system" | "user";
        content: string;
    }>;
    temperature?: number;
    max_output_tokens?: number;
}

interface OpenAIResponsesResult {
    // The Responses API returns a convenience `output_text` field; we also
    // walk `output[].content[]` as a fallback for robustness.
    output_text?: string;
    output?: Array<{
        content?: Array<{ type: string; text?: string }>;
    }>;
    error?: { message?: string };
}

// -----------------------------------------------------------------------------
// Config
// -----------------------------------------------------------------------------
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";
const OPENAI_ENDPOINT = "https://api.openai.com/v1/responses";

const CORS_HEADERS: Record<string, string> = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
function jsonResponse(status: number, body: unknown): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
}

function buildSystemPrompt(tone: CoachingTone): string {
    const toneHint: Record<CoachingTone, string> = {
        calm: "Use a calm, grounded, unhurried voice.",
        practical: "Use a pragmatic, direct, action-oriented voice.",
        tough_love: "Use a warm but firm voice; be honest, no sugar-coating.",
        reflective: "Use a reflective, curious voice; ask a gentle question if useful.",
    };

    return [
        "You are a warm, practical daily wellness coach.",
        "You help the user make small, sustainable progress across three life zones: Self (health/mindset), Purpose (work/goals), and Loved Ones (family/relationships).",
        toneHint[tone],
        "You NEVER diagnose medical or mental-health conditions. If the user describes a crisis, acknowledge it briefly and suggest they contact a local professional or emergency service.",
        "Respond with exactly ONE short reflection sentence, then 1 to 3 concrete next-step actions.",
        "Output MUST be valid JSON with shape: {\"reply\": string, \"actions\": string[]}.",
        "Keep `reply` under 240 characters. Each action under 120 characters. Do not include markdown, code fences, or commentary outside the JSON.",
    ].join(" ");
}

function buildUserContext(
    profile: ProfileRow,
    summary: SummaryRow | null,
    checkins: CheckinAggregates | null,
    zones: ZoneBalance | null,
    userMessage: string,
): string {
    // A structured text block. No raw journal content, no PII.
    const lines: string[] = [];
    lines.push("USER CONTEXT (structured, no raw journal text):");
    lines.push(`- goal: ${profile.goal ?? "(not set)"}`);
    lines.push(`- coaching_tone: ${profile.coaching_tone}`);
    lines.push(`- preferred_zone: ${profile.preferred_zone ?? "(not set)"}`);

    if (checkins) {
        lines.push("- last_7_checkins:");
        lines.push(`    days_logged: ${checkins.days_logged}`);
        lines.push(`    avg_mood: ${checkins.avg_mood ?? "n/a"}`);
        lines.push(`    avg_stress: ${checkins.avg_stress ?? "n/a"}`);
        lines.push(`    avg_energy: ${checkins.avg_energy ?? "n/a"}`);
        lines.push(`    avg_sleep: ${checkins.avg_sleep ?? "n/a"}`);
        lines.push(`    habit_days: ${checkins.habit_days}`);
    } else {
        lines.push("- last_7_checkins: (none)");
    }

    if (zones) {
        lines.push("- zone_balance_7d:");
        lines.push(`    self_days: ${zones.self_days}`);
        lines.push(`    purpose_days: ${zones.purpose_days}`);
        lines.push(`    loved_ones_days: ${zones.loved_ones_days}`);
    } else {
        lines.push("- zone_balance_7d: (none)");
    }

    if (summary) {
        lines.push(`- summary_text: ${summary.summary_text}`);
    } else {
        lines.push("- summary_text: (none yet — user is new or summariser hasn't run)");
    }

    lines.push("");
    lines.push("CURRENT USER TURN:");
    lines.push(userMessage);
    return lines.join("\n");
}

function extractResponseText(result: OpenAIResponsesResult): string {
    if (typeof result.output_text === "string" && result.output_text.length > 0) {
        return result.output_text;
    }
    const chunks: string[] = [];
    for (const o of result.output ?? []) {
        for (const c of o.content ?? []) {
            if (c.type && typeof c.text === "string") chunks.push(c.text);
        }
    }
    return chunks.join("\n").trim();
}

function parseModelJson(raw: string): CoachReply {
    // The model is instructed to return strict JSON. Be defensive: strip
    // accidental code fences and extract the first {...} block.
    let text = raw.trim();
    if (text.startsWith("```")) {
        text = text.replace(/^```(?:json)?\s*/i, "").replace(/```$/i, "").trim();
    }
    const firstBrace = text.indexOf("{");
    const lastBrace = text.lastIndexOf("}");
    if (firstBrace >= 0 && lastBrace > firstBrace) {
        text = text.slice(firstBrace, lastBrace + 1);
    }
    try {
        const parsed = JSON.parse(text) as Partial<CoachReply>;
        const reply = typeof parsed.reply === "string" ? parsed.reply.trim() : "";
        const actions = Array.isArray(parsed.actions)
            ? parsed.actions.filter((a): a is string => typeof a === "string").map((a) => a.trim()).filter(Boolean)
            : [];
        if (!reply) throw new Error("Model returned empty reply.");
        return { reply, actions };
    } catch {
        // Fallback: treat the whole thing as the reply with no actions.
        return { reply: raw.trim(), actions: [] };
    }
}

// -----------------------------------------------------------------------------
// Data loaders — all run with the *user's* JWT so RLS is enforced.
// -----------------------------------------------------------------------------
async function loadProfile(sb: SupabaseClient, userId: string): Promise<ProfileRow> {
    const { data, error } = await sb
        .from("profiles")
        .select("user_id, goal, coaching_tone, preferred_zone")
        .eq("user_id", userId)
        .single();
    if (error) throw new Error(`profile load failed: ${error.message}`);
    return data as ProfileRow;
}

async function loadLatestSummary(sb: SupabaseClient, userId: string): Promise<SummaryRow | null> {
    const { data, error } = await sb
        .from("ai_summaries")
        .select("summary_text, aggregates, window_start, window_end")
        .eq("user_id", userId)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
    if (error) throw new Error(`summary load failed: ${error.message}`);
    return (data as SummaryRow | null) ?? null;
}

async function loadCheckinAggregates(sb: SupabaseClient): Promise<CheckinAggregates | null> {
    // View is filtered by auth.uid() internally.
    const { data, error } = await sb
        .from("v_last_7_checkins")
        .select("days_logged, avg_mood, avg_stress, avg_energy, avg_sleep, habit_days")
        .maybeSingle();
    if (error) throw new Error(`checkin aggregates load failed: ${error.message}`);
    return (data as CheckinAggregates | null) ?? null;
}

async function loadZoneBalance(sb: SupabaseClient): Promise<ZoneBalance | null> {
    const { data, error } = await sb
        .from("v_zone_balance_7d")
        .select("self_days, purpose_days, loved_ones_days")
        .maybeSingle();
    if (error) throw new Error(`zone balance load failed: ${error.message}`);
    return (data as ZoneBalance | null) ?? null;
}

async function persistMessages(
    sb: SupabaseClient,
    userId: string,
    userMessage: string,
    coachReply: string,
): Promise<void> {
    const { error } = await sb.from("coach_messages").insert([
        { user_id: userId, role: "user", content: userMessage },
        { user_id: userId, role: "coach", content: coachReply },
    ]);
    if (error) throw new Error(`coach_messages insert failed: ${error.message}`);
}

// -----------------------------------------------------------------------------
// OpenAI call
// -----------------------------------------------------------------------------
async function callOpenAI(systemPrompt: string, userContext: string): Promise<string> {
    const payload: OpenAIResponsesPayload = {
        model: OPENAI_MODEL,
        input: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userContext },
        ],
        temperature: 0.6,
        max_output_tokens: 400,
    };

    const res = await fetch(OPENAI_ENDPOINT, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${OPENAI_API_KEY}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
    });

    if (!res.ok) {
        const text = await res.text();
        throw new Error(`OpenAI HTTP ${res.status}: ${text}`);
    }

    const result = (await res.json()) as OpenAIResponsesResult;
    if (result.error?.message) throw new Error(`OpenAI error: ${result.error.message}`);

    const text = extractResponseText(result);
    if (!text) throw new Error("OpenAI returned empty response.");
    return text;
}

// -----------------------------------------------------------------------------
// Handler
// -----------------------------------------------------------------------------
Deno.serve(async (req: Request): Promise<Response> => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: CORS_HEADERS });
    }
    if (req.method !== "POST") {
        return jsonResponse(405, { error: "method_not_allowed" });
    }

    // --- Auth ---
    const authHeader = req.headers.get("Authorization") ?? req.headers.get("authorization");
    if (!authHeader || !authHeader.toLowerCase().startsWith("bearer ")) {
        return jsonResponse(401, { error: "missing_bearer_token" });
    }

    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
        return jsonResponse(500, { error: "supabase_env_missing" });
    }
    if (!OPENAI_API_KEY) {
        return jsonResponse(500, { error: "openai_key_missing" });
    }

    // Per-request Supabase client bound to the CALLER's JWT so RLS applies.
    // The anon key is the publishable key; the Bearer JWT is what authorises.
    const sb: SupabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        global: { headers: { Authorization: authHeader } },
        auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: userResult, error: userErr } = await sb.auth.getUser();
    if (userErr || !userResult?.user) {
        return jsonResponse(401, { error: "invalid_token" });
    }
    const userId = userResult.user.id;

    // --- Validate body ---
    let body: RequestBody;
    try {
        body = (await req.json()) as RequestBody;
    } catch {
        return jsonResponse(400, { error: "invalid_json" });
    }

    const userMessage = typeof body.user_message === "string" ? body.user_message.trim() : "";
    if (!userMessage) {
        return jsonResponse(400, { error: "user_message_required" });
    }
    if (userMessage.length > 4000) {
        return jsonResponse(400, { error: "user_message_too_long" });
    }

    // --- Load structured, privacy-safe context ---
    let profile: ProfileRow;
    let summary: SummaryRow | null;
    let checkins: CheckinAggregates | null;
    let zones: ZoneBalance | null;
    try {
        [profile, summary, checkins, zones] = await Promise.all([
            loadProfile(sb, userId),
            loadLatestSummary(sb, userId),
            loadCheckinAggregates(sb),
            loadZoneBalance(sb),
        ]);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return jsonResponse(500, { error: "context_load_failed", detail: msg });
    }

    // --- Compose prompt & call OpenAI ---
    const systemPrompt = buildSystemPrompt(profile.coaching_tone);
    const userContext = buildUserContext(profile, summary, checkins, zones, userMessage);

    let rawModelText: string;
    try {
        rawModelText = await callOpenAI(systemPrompt, userContext);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return jsonResponse(502, { error: "upstream_openai_failed", detail: msg });
    }

    const parsed = parseModelJson(rawModelText);

    // --- Persist transcript (current turn only; history is never re-sent upstream) ---
    try {
        await persistMessages(sb, userId, userMessage, parsed.reply);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        // Non-fatal for the user-facing reply but worth surfacing.
        return jsonResponse(500, { error: "persist_failed", detail: msg });
    }

    return jsonResponse(200, parsed);
});
