# Project context for Claude Code

This file auto-loads into every Claude Code session opened in this folder. Keep it concise — detail lives in `HANDOVER.md` and `docs/`.

## What this project is

A daily wellness Android app (working title: **Daily Tend** — chosen 2026-04-29, was "Wellness Works"; name may still change, do NOT bake it into identifiers or copy). Helps users balance energy across **Three Energy Zones** — Self / Purpose / Loved Ones — via a sub-60-second daily check-in, a rules-driven daily plan, and an AI coach.

- **Audience:** general public — busy adults, parents, people feeling stuck. NOT athletes, NOT biohackers, NOT therapy users.
- **Positioning:** the warmer, more human alternative to Calm / Finch / Fabulous / Headspace.

## Locked tech decisions

- **Flutter** (stable channel), Android build first, iOS deferred
- **Supabase** (auth + Postgres + Edge Functions); Row-Level Security on every table
- **OpenAI Responses API** for the coach, proxied via a Supabase Edge Function — API key never in the app
- **Riverpod** + **GoRouter** (state + nav)
- **Drift** for offline check-in cache
- **Package ID:** neutral (TBD when scaffolding — not `com.wellnessworks.*`)

## Non-negotiable privacy posture

- **Raw reflection notes and prior coach messages never leave Supabase.** OpenAI only receives: profile context, numeric aggregates, a rules-engine summary, and the current turn.
- Row-Level Security (`user_id = auth.uid()`) on every table.
- Medical disclaimer surfaced in onboarding and settings.

Any change that would weaken this posture must be raised with the founder first.

## Voice (when writing any user-visible copy)

Warm, concise, human. No toxic positivity. No clinical jargon. No streak-shame. Australian/UK English ("colour", "personalise"). Use `{app_name}` as a placeholder so a rename is a find-and-replace. Full spec: `docs/voice.md`.

## Build status

Pre-V1. Scaffolding in progress. See `HANDOVER.md` for exactly what's done, what's pending, and what decisions still need the founder's answer.

## File map

```
.
├── CLAUDE.md                        ← this file
├── HANDOVER.md                      ← start here when picking up work
├── README.md                        ← public-facing overview
├── SETUP.md                         ← developer install checklist
├── app/                             ← Flutter app (not yet scaffolded)
├── supabase/                        ← backend: migrations + Edge Functions
│   ├── migrations/001_init.sql
│   └── functions/{generate_coach_reply,nightly_summariser}/
├── docs/
│   ├── plan.md                      ← approved implementation plan
│   ├── voice.md, copy_library.md    ← brand voice + all UI copy
│   ├── content/                     ← goals, habits, day-type actions
│   └── design/                      ← design system + tokens + a11y
├── .github/workflows/android.yml    ← CI
└── wellness_works_flash_drive_pack_v2/  ← original handover pack (read-only)
```

## Ground rules

- **Don't bake the brand name** into package IDs, table names, function names, asset filenames, or copy that would cascade on rename. Use `{app_name}` in copy.
- **Don't commit secrets.** OpenAI + Supabase service-role keys live only in Supabase Edge Function environment variables (`supabase secrets set ...`). No `.env` files in git.
- **Use Australian/UK spellings** in all user-facing copy.
- **Respect the phase plan** in `docs/plan.md` unless the founder explicitly reprioritises.
- **Ask before big architectural pivots** — the founder has veto on stack changes, privacy posture, and voice.
