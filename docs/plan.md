# Wellness Works — Android V1 Implementation Plan

> This is the approved implementation plan, archived into the project from the Claude Code plan mode session on **2026-04-23**. It is the source of truth for phase order and scope. Live status is in [`../HANDOVER.md`](../HANDOVER.md). Decisions made after approval are captured at the bottom of this file.

## Context

The user is building **Wellness Works** (working title), a mass-market wellness app for the general public — people dealing with stress, low energy, poor routines, and inconsistency. The product promise: *"A wellness app that learns your patterns, adapts to real life, and helps you build better days through small personalised actions."*

The differentiating concept pulled from the One-Page Concept is the **Three Energy Zones** (Self / Purpose / Loved Ones): rather than tracking wellness in a vacuum, the app helps users balance energy across their own wellbeing, their work/goals, and the people who matter to them. Every existing wellness app picks one lane (meditation, habits, therapy-style, fitness); Wellness Works connects the full picture and uses AI + rules to nudge what's been neglected.

V1 ships **Android only** (iOS port later). The user will use Claude Code to build it incrementally with no hard deadline — quality over speed. Free-only at launch; paywall in V1.1. All content below is drawn from the handover pack (Build Brief, Handover Pack v2, One-Page Concept, Crib Sheets, Proposal Deck) plus decisions gathered in this session.

## Locked decisions

| Area | Decision |
|---|---|
| Platform | Android-only V1 (Flutter); iOS deferred |
| Stack | Flutter stable, Supabase (auth + Postgres + Edge Functions), OpenAI Responses API |
| State / routing | Riverpod + GoRouter |
| Auth | Email/password + Google Sign-In (Supabase Auth) |
| Data model | Three Zones are first-class (Self / Purpose / Loved Ones) |
| Personalisation | Rules-based engine in V1; no ML |
| AI privacy | Summarised context only — raw reflection notes never sent to OpenAI |
| AI transport | Client → Supabase Edge Function → OpenAI (API key server-side) |
| Monetisation | Free-only at launch. Google Play Billing + Premium in V1.1 |
| Reminders | Smart-time: algorithm learns user's typical check-in window after ~7 days |
| Android polish | Home-screen widget, notification quick-actions, Health Connect, Material You dynamic colours |
| Branding | "Wellness Works" is working title; neutral package ID, swappable assets. Logo sourced externally by user |
| Voice | Drafted by Claude in Phase 0 — warm, concise, no toxic positivity, no clinical jargon |
| Build mode | Claude Code implements; user iterates |

## Architecture

### Dependencies (pubspec)
- `flutter_riverpod`, `go_router`
- `supabase_flutter`
- `drift` + `sqlite3_flutter_libs` — offline check-in cache
- `flutter_secure_storage` — tokens
- `health` — Health Connect reads (sleep, steps)
- `awesome_notifications` — quick-action notifications
- `home_widget` — Kotlin widget bridge
- `dynamic_color` — Material You
- `sentry_flutter` — crash reporting
- `fl_chart` — progress visualisations

### Supabase schema
- `profiles` — user_id FK auth, display_name, goal, coaching_tone, preferred_zone, reminder_time_learned, onboarding_complete
- `check_ins` — user_id, mood, stress, energy, sleep, habit_completion, focus_zone (enum: self/purpose/loved_ones), reflection_note, created_at
- `daily_plans` — user_id, date, primary_focus_zone, action_self, action_purpose, action_loved_ones, recovery_action, source (rules/ai)
- `habits` — user_id, name, zone, cadence
- `habit_logs` — habit_id, date, completed
- `ai_summaries` — user_id, window_start, window_end, summary_text (the scrubbed context sent to OpenAI)
- `coach_messages` — user_id, role, content (raw text stays in Supabase, never in upstream calls beyond the current turn)
- `subscriptions` — placeholder for V1.1

Row-Level Security on every table: `user_id = auth.uid()`. Migrations checked into `supabase/migrations/`.

### AI coach privacy flow
Edge Function `generate_coach_reply` composes the prompt from:
1. Profile (goal, coaching_tone, preferred_zone)
2. Numeric aggregates from last 7 check-ins (avg mood trend, zone balance, sleep-stress correlation)
3. The most recent row from `ai_summaries` — a rules-engine-generated paragraph like *"User has had three low-energy days, responds well to short practical prompts, has been neglecting Loved Ones zone."*
4. The current user turn only

`reflection_note` fields and prior `coach_messages` are **never** included. A nightly `nightly_summariser` Edge Function rebuilds `ai_summaries` from structured fields only.

### Rules engine (V1)
Day-type classification from the brief:
- poor sleep + high stress → **recovery day**
- low mood + low energy → **gentle day**
- high energy + low stress → **momentum day**
- otherwise → **balanced day**

Each day-type maps to a pattern of zone actions pulled from a curated library (`lib/core/rules/action_library.dart`). Zone balance tracking: if one zone hasn't been the focus in 5+ days, bias today's primary_focus_zone toward it.

## Screens (GoRouter routes)

- `/` splash
- `/auth/welcome` sign up / sign in
- `/onboarding/*` — 6 steps: name → main goal → stress baseline → energy baseline → sleep quality → coaching tone. Target <3 min.
- `/home` — dashboard: today's focus card, one action per zone, recovery action, check-in CTA
- `/checkin` — modal: mood / stress / energy / sleep / habit ticks / zone-focus / optional reflection note. Target <60 sec.
- `/coach` — chat interface
- `/progress` — 7-day trends + zone-balance donut + weekly reflection card
- `/settings` — profile, reminders, privacy controls, subscription (placeholder), logout, medical disclaimer

Android extras:
- Home-screen widget → 1-tap mood + deep-link to `/checkin` with mood pre-filled
- Notification quick-action buttons → silent-submit mood+energy without opening app

## Build order

**Phase 0 — Foundation (Week 1)**
- Flutter project init, neutral package ID
- Supabase project + schema + RLS + migrations
- GitHub Actions: build + AAB artefact
- Theme tokens (proposed palette: warm off-whites, sage/clay accents), typography scale
- Voice guide draft: 15 sample lines across coach replies, reminders, empty states, errors
- Riverpod + GoRouter scaffold

**Phase 1 — Auth + Onboarding (Week 2)**
- Supabase Auth (email + Google)
- 6-step onboarding → writes `profiles` row
- Medical disclaimer acknowledged during onboarding

**Phase 2 — Check-in + offline cache (Weeks 3–4)**
- Check-in modal with zone-focus question as first-class step
- Drift local cache; background sync to Supabase
- Rules engine v1 implemented and unit-tested
- Timestamp capture for smart-reminder learning

**Phase 3 — Home dashboard (Week 5)**
- Today's focus card
- Zone-balanced daily plan generated by rules engine at first check-in of the day

**Phase 4 — AI coach (Weeks 6–7)**
- Edge Function `generate_coach_reply` with privacy-safe prompt composition
- Edge Function `nightly_summariser` (scheduled via pg_cron)
- Coach chat UI with streaming responses

**Phase 5 — Progress (Week 8)**
- 7-day trend lines (mood / stress / energy / sleep)
- Zone-balance donut
- Rules-driven weekly reflection card (AI-generated version in V1.1)

**Phase 6 — Android polish (Weeks 9–10)**
- Home-screen widget (Kotlin + `home_widget`)
- Notification quick-actions (`awesome_notifications`)
- Health Connect: pre-fill sleep score from overnight data, pre-fill activity signal
- Material You dynamic colours with graceful fallback palette
- Smart reminder: after 7 days of check-in data, suggest reminder time = mode of user's check-in hours

**Phase 7 — Settings + launch prep (Weeks 11–12)**
- Full settings screen
- Privacy policy + terms (user reviews before submission)
- Sentry wired
- Play Store listing draft
- Internal testing → closed beta → production

**V1.1 (post-launch)**
- Google Play Billing + Premium feature gates (unlimited coach, full history, AI-generated weekly reports, pattern insights, personalised daily plans)
- Paywall screens with clean cancellation messaging

## Verification

Smoke test at each phase close:
- **P1**: new user signs up with Google, completes onboarding, lands on home (empty state).
- **P2**: check-in persists offline, syncs, appears in Supabase. Rules engine unit tests cover all 4 day-types.
- **P3**: generated daily plan matches rule for current day-type; zone bias triggers when one zone neglected 5+ days.
- **P4**: coach reply <5s; inspect Edge Function logs to **confirm no raw reflection_note text was sent to OpenAI**.
- **P5**: progress screen renders correct last-7-days aggregates; zone donut matches check-in history.
- **P6**: widget writes a `check_ins` row with identical schema to in-app; Health Connect sleep value pre-fills check-in slider; app palette shifts when device wallpaper changes.
- **P7**: Play Store internal-test AAB installs cleanly, runs end-to-end on a real device, no crashes in 24h soak.

V1 launch acceptance:
- Check-in completable in <60s on a real device
- Onboarding <3 minutes
- Audit: no raw journal text in OpenAI payloads (verified from Edge Function logs)
- No crashes in 24h of closed-beta use
- Voice guide applied to 100% of user-visible strings

## Post-approval decisions (2026-04-23)

These were decided AFTER the plan was approved and should be treated as equally binding:

- **Backend:** Supabase confirmed over Firebase. Rationale: real PostgreSQL + Row-Level Security matches the health-data trust story better than Firestore; open-source portability vs Google lock-in.
- **Rules engine day_type names finalised** in the Supabase schema as enum `day_type` = `recovery | gentle | momentum | balanced` (all four used across the action library).

## Open items (flagged, not blocking)

See [`../HANDOVER.md`](../HANDOVER.md) for the live list of open decisions awaiting the founder's confirmation.
