# Wellness Works (working title)

A daily wellness companion for real life. Helps people understand their patterns, feel supported, and take one small useful action across **three energy zones** — Self, Purpose, and Loved Ones.

V1 is **Android only**. iOS will follow once V1 is stable.

## Positioning

Most wellness apps pick a single lane — meditation, habits, therapy-style, fitness. This one connects the full picture: how someone's energy gets spent across themselves, their work, and the people they care about, then nudges what's been neglected.

Target users: busy adults, parents, people feeling stuck. Not athletes, not biohackers.

## What V1 includes

- Sign up + Google Sign-In
- ~3-minute onboarding (name, goal, baselines, coaching tone)
- Sub-60-second daily check-in (mood, stress, energy, sleep, habit, zone focus, optional note)
- Rules-based daily plan (one action per zone + recovery action, sensitive to the day's "type")
- AI coach (warm, practical, short — never sees raw journal text)
- 7-day progress trends + zone-balance view + weekly reflection
- Smart-time reminders (learned from usage)
- Home-screen widget + notification quick-actions
- Health Connect integration (sleep + activity)
- Material You dynamic colours

**Not in V1:** paywall, community, content library, wearables beyond Health Connect, advanced ML.

V1.1 adds Google Play Billing + Premium (unlimited coach, richer insights, full history, AI-generated weekly reports).

## Stack

- **Flutter** (stable) — single codebase, ships Android first
- **Supabase** — auth, PostgreSQL, Row-Level Security, Edge Functions
- **OpenAI Responses API** — AI coach, proxied via Supabase Edge Function (API key server-side)
- **Riverpod** + **GoRouter** for state and navigation
- **Drift** for offline check-in cache
- **Sentry** for crash reporting
- **PostHog or Firebase Analytics** for product analytics (decided at Phase 4)

## Repository layout

```
.
├── app/                        # Flutter app (Android target)
├── supabase/
│   ├── migrations/             # SQL migrations (schema + RLS)
│   └── functions/              # Edge Functions (Deno/TS)
│       ├── generate_coach_reply/
│       └── nightly_summariser/
├── docs/
│   ├── voice.md                # Brand voice + tone guide
│   ├── copy_library.md         # All user-facing UI copy
│   ├── content/                # Goals, habits, day-type actions
│   └── design/                 # Design system, tokens, accessibility
├── .github/workflows/          # CI
├── SETUP.md                    # One-time developer setup
└── README.md
```

## Privacy posture

- Raw reflection notes and prior coach messages **never leave Supabase**.
- OpenAI only receives: profile context, numeric aggregates, a rules-engine-generated summary, and the current turn.
- Row-Level Security on every table (`user_id = auth.uid()`).
- Medical disclaimer surfaced in onboarding and settings.

## Getting started

- [**SETUP.md**](SETUP.md) — install Flutter, JDK 17, Supabase, OpenAI
- [**HANDOVER.md**](HANDOVER.md) — current status, locked decisions, open questions, next steps
- [**docs/plan.md**](docs/plan.md) — approved implementation plan (phase-by-phase)
- [**CLAUDE.md**](CLAUDE.md) — auto-loaded into Claude Code sessions opened in this folder

## Status

Pre-V1. Scaffolding in progress. See [HANDOVER.md](HANDOVER.md) for what's done and what's next.
