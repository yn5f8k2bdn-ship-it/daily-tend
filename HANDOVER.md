# Handover — picking this project up

Read this first if you're a new collaborator (human or AI) joining this project. It captures the state as of **2026-04-29**.

> **Project moved 2026-04-29.** Canonical location: `C:\dev\daily-tend\`. Was at `c:\Users\lhill\OneDrive\Documents\Wellness Work\Wellness Works\` until OneDrive sync started locking Flutter's `build/` folder. The OneDrive copy is now stale — treat this `C:\dev\daily-tend\` tree as authoritative.

The approved implementation plan lives at [`docs/plan.md`](docs/plan.md). This file is the live status + open-decisions view.

## Project intent in one paragraph

A mass-market Android wellness app (working title: **Daily Tend** — chosen 2026-04-29, was "Wellness Works"). Daily check-in + AI coach + rules-based daily plan, organised around **Three Energy Zones** (Self / Purpose / Loved Ones). Positioned as the warmer, more human alternative to Calm / Finch / Fabulous / Headspace. V1 free-only; paywall + Premium in V1.1. Android only for V1; iOS deferred. See the original brief in [`Wellness_Works_App_Handover_Pack_v2.docx`](Wellness_Works_App_Handover_Pack_v2.docx) and concept in [`Wellness_Works_One_Page_Concept_Handover.docx`](Wellness_Works_One_Page_Concept_Handover.docx).

## What's done ✅

- **Project brief + plan** agreed and written: [`docs/plan.md`](docs/plan.md)
- **Supabase backend — fully deployed (2026-05-03)**
  - Project URL: `https://fpgadotiobvesybkeemz.supabase.co` (project ref `fpgadotiobvesybkeemz`)
  - Publishable (anon) key wired into [`app/lib/config/supabase_config.dart`](app/lib/config/supabase_config.dart)
  - Migration applied via dashboard SQL editor — 8 tables + RLS + triggers + views confirmed: [`supabase/migrations/001_init.sql`](supabase/migrations/001_init.sql)
  - `pg_cron` extension enabled in Database → Extensions
  - Edge Function `generate_coach_reply` deployed via dashboard "Via Editor": [`supabase/functions/generate_coach_reply/index.ts`](supabase/functions/generate_coach_reply/index.ts)
  - Edge Function `nightly_summariser` deployed via dashboard "Via Editor": [`supabase/functions/nightly_summariser/index.ts`](supabase/functions/nightly_summariser/index.ts)
  - Secrets `OPENAI_API_KEY` and `OPENAI_MODEL` set in Edge Functions → Secrets
  - Deploy + local-dev README: [`supabase/README.md`](supabase/README.md)
  - **Caveat:** external probes to `generate_coach_reply` 404 because Supabase's default "Verify JWT" gating rejects requests without a real user-session JWT. Real validation happens once Flutter auth is wired. NOT a deploy bug.
- **Brand voice + content library — complete**
  - Voice spec with all 4 coaching-tone variants: [`docs/voice.md`](docs/voice.md)
  - Full UI copy library (uses `{app_name}` placeholder): [`docs/copy_library.md`](docs/copy_library.md)
  - Onboarding goals (9 options): [`docs/content/goals.md`](docs/content/goals.md)
  - Habit library (24 habits, 8 per zone): [`docs/content/habits.md`](docs/content/habits.md)
  - Day-type action library (80 entries): [`docs/content/actions.md`](docs/content/actions.md)
- **Design system — complete**
  - Palette + type + components + zone visual identity: [`docs/design/design_system.md`](docs/design/design_system.md)
  - Machine-readable tokens (Design Tokens CG format): [`docs/design/tokens.json`](docs/design/tokens.json)
  - Material You dynamic-colour mapping: [`docs/design/material_you.md`](docs/design/material_you.md)
  - Accessibility spec + contrast matrices: [`docs/design/accessibility.md`](docs/design/accessibility.md)
- **Flutter app — auth, onboarding persistence, and daily check-in submit all working end-to-end (2026-05-17)**
  - Package name: `three_zones` (neutral, kept stable across any rename)
  - Single source of truth for the brand name: [`app/lib/app_constants.dart`](app/lib/app_constants.dart) (`kAppName = 'Daily Tend'`)
  - Dependencies pinned in [`app/pubspec.yaml`](app/pubspec.yaml): `flutter_riverpod ^3.3.1`, `go_router ^17.2.2`, `google_fonts ^8.1.0`, `google_sign_in ^7.2.0`, `supabase_flutter ^2.12.4`
  - Riverpod root + Supabase init + GoRouter wired in [`app/lib/main.dart`](app/lib/main.dart)
  - Design tokens translated to Dart: [`app/lib/theme/app_tokens.dart`](app/lib/theme/app_tokens.dart) (honey primary + deep-teal secondary + frozen zone accents, light & dark) and theme assembled in [`app/lib/theme/app_theme.dart`](app/lib/theme/app_theme.dart)
  - White-to-teal gradient background applied app-wide via [`app/lib/widgets/gradient_background.dart`](app/lib/widgets/gradient_background.dart)
  - **Auth:** Riverpod providers in [`app/lib/auth/auth_providers.dart`](app/lib/auth/auth_providers.dart) (`signedInProvider`, `currentUserProvider`, stream from `onAuthStateChange`); `AuthController` in [`app/lib/auth/auth_controller.dart`](app/lib/auth/auth_controller.dart) covers email/password sign-up + sign-in, native Google Sign-In via `signInWithIdToken`, and sign-out. Sign-up/sign-in UI in [`app/lib/screens/auth/sign_in_screen.dart`](app/lib/screens/auth/sign_in_screen.dart); Google button wired on [`welcome_screen.dart`](app/lib/screens/welcome/welcome_screen.dart). Tested end-to-end on Android emulator including Google 2FA prompt flow.
  - **Profile:** model in [`app/lib/data/profile.dart`](app/lib/data/profile.dart) (Dart `CoachingTone` + `Zone` enums mirror Postgres enums with `wireName` round-trip). Repository at [`app/lib/data/profile_repository.dart`](app/lib/data/profile_repository.dart) + `currentProfileProvider`.
  - **Router gating:** [`app/lib/routing/app_router.dart`](app/lib/routing/app_router.dart) is now a Riverpod provider with a redirect that gates routes on auth state + `profile.onboarding_complete`. A `_RouterRefresh` ChangeNotifier wakes GoRouter when either fires.
  - **Onboarding persistence:** screens 1/2/6 (`name`, `goal`, `tone`) write to `profiles` on each Continue; the tone screen also flips `onboarding_complete = true`. Stress/energy/sleep screens are still UI-only — they'll become the first daily check-in in a follow-up. See screens under [`app/lib/screens/onboarding/`](app/lib/screens/onboarding/) and content data in [`app/lib/data/onboarding_content.dart`](app/lib/data/onboarding_content.dart).
  - **Check-in submit:** repository at [`app/lib/data/checkin_repository.dart`](app/lib/data/checkin_repository.dart) does `upsert` on `(user_id, local_date)` so re-submits replace today's row rather than erroring. Modal at [`app/lib/screens/checkin/check_in_modal.dart`](app/lib/screens/checkin/check_in_modal.dart) collects + submits + shows a spinner during the network round-trip.
  - **Home dashboard** ([`app/lib/screens/home/home_dashboard_screen.dart`](app/lib/screens/home/home_dashboard_screen.dart)) reads `currentProfileProvider` for a personalised greeting and `todayCheckinProvider` to swap "Today's check-in is waiting" for "[Zone] · today ✓" once the user has checked in. Three zone-action cards still placeholder until rules engine lands.
  - **Settings → Log out** wired to `AuthController.signOut()` ([`app/lib/screens/settings/settings_screen.dart`](app/lib/screens/settings/settings_screen.dart)); router redirect bounces back to Welcome.
  - **Android manifest** ([`app/android/app/src/main/AndroidManifest.xml`](app/android/app/src/main/AndroidManifest.xml)) adds `android.permission.INTERNET` and sets `android:label="Daily Tend"`.
  - **Web OAuth client ID** baked into [`app/lib/config/supabase_config.dart`](app/lib/config/supabase_config.dart) as `googleWebClientId`. Safe to ship — only the matching client *secret* is sensitive and lives in Supabase only.
  - Reusable widgets: [`five_point_scale.dart`](app/lib/widgets/five_point_scale.dart), [`zone_balance_hero.dart`](app/lib/widgets/zone_balance_hero.dart), [`zone_segmented.dart`](app/lib/widgets/zone_segmented.dart), [`onboarding_scaffold.dart`](app/lib/widgets/onboarding_scaffold.dart)
- **CI** — GitHub Actions workflow for analyse + test + AAB build: [`.github/workflows/android.yml`](.github/workflows/android.yml)
- **Developer setup** checklist: [`SETUP.md`](SETUP.md)

## What's pending 🟡

1. **Drift offline cache for check-ins** — locked tech decision but not yet implemented. Add `drift` + codegen, schema mirroring `check_ins`, sync queue, connectivity detection, write-through; replaces direct Supabase write in [`CheckinRepository`](app/lib/data/checkin_repository.dart). ~1.5-2 hours of focused work.
2. **Implement coach screen** against the `generate_coach_reply` Edge Function — POST with the user's session JWT in the Authorization header. UI shell exists at [`app/lib/screens/coach/coach_screen.dart`](app/lib/screens/coach/coach_screen.dart) but is static.
3. **Capture stress/energy/sleep as first check-in** — those three onboarding screens currently just navigate. They should either write a check-in on completion of onboarding, or be removed in favour of just prompting the first proper check-in via the FAB.
4. **Schedule `nightly_summariser`** via `pg_cron` — needs a SQL snippet plus the service-role key in Supabase Vault per [`supabase/README.md`](supabase/README.md).
5. **Rules engine for daily plan** — derive `day_type` + three zone-action strings from today's check-in. Home dashboard's "Three small things" are still static placeholders.
6. **Continue phases 4–7** of [`docs/plan.md`](docs/plan.md) — progress charts, settings polish, reminders/widget, Health Connect.
7. **Re-enable Supabase email confirmation + configure Site URL + redirect templates** before any production sign-ups (currently OFF for dev convenience).
8. **Production signing config** — release keystore + register its SHA-1 with a new Google Cloud Android OAuth client before Play Store submission. Debug keystore is dev-only.

## Decisions locked by the founder

| Area | Decision | When decided |
|---|---|---|
| Platform | Android-only V1; iOS later | 2026-04-23 |
| Stack | Flutter + Supabase + OpenAI Responses API | handover brief |
| Three Zones | Zones drive check-in AND the daily plan in V1 | 2026-04-23 |
| Monetisation | Free-only at launch. Paywall + Premium in V1.1 | 2026-04-23 |
| Auth | Email/password + Google Sign-In | 2026-04-23 |
| Brand name | Working title now **"Daily Tend"** (was "Wellness Works"); still swappable. Set in [`app/lib/app_constants.dart`](app/lib/app_constants.dart) (`kAppName`) — change one line to rename. | 2026-04-29 |
| Logo | Founder sourcing externally from another AI | 2026-04-23 |
| Reminders | Smart-time: learn user's check-in hour after ~7 days | 2026-04-23 |
| Android polish | Widget + notification quick-actions + Health Connect + Material You (all in V1) | 2026-04-23 |
| AI privacy | Summarised context only; raw notes never leave Supabase | 2026-04-23 |
| Voice | Drafted fresh by Claude; founder to review | 2026-04-23 |
| Timeline | Quality over speed, no hard deadline | 2026-04-23 |
| Build team | Claude Code implements, founder iterates | 2026-04-23 |
| Backend | Supabase confirmed (over Firebase alternative) | 2026-04-23 |
| Primary colour | **Honey `#D9A04C`** (light) / `#E8B86E` (dark). Iterated from clay via the teal-gradient experiment. Dark-brown text on honey (white fails AA Large). | 2026-04-29 |
| Secondary colour | **Deep teal `#2E6B73`** — sibling to the gradient teal `#54A4AE`. Replaced sage (sage sat too close to gradient teal). | 2026-04-29 |
| Background | White-to-teal gradient applied app-wide | 2026-04-29 |
| OpenAI model | GPT-5 family (founder said "gpt-5.5"; Edge Function reads `OPENAI_MODEL` from secrets, set to canonical 5.x ID at deploy time) | 2026-04-29 |
| Check-in placement | **FAB-modal** on Home and Progress (not a nav tab). Bottom nav = Home / Progress / Coach / Settings | 2026-04-29 |
| Zone colours | Frozen against Material You. Neutrals/primary/secondary adopt wallpaper-derived scheme on Android 12+; zones + semantic colours stay frozen | 2026-04-29 |

## Open decisions — still to resolve

### Medium impact (copy / content)

- [ ] **No weight-loss / fitness / therapy framing** in onboarding goals (9 options, not 10). Confirm.
- [ ] **No alcohol/food moralising** in action library. Confirm or relax.
- [ ] **"Private mode" settings toggle** (hides notes behind device passcode): not in brief, added by agent. Keep or drop?
- [ ] **Loved-Ones zone colour:** muted rose `#A8678A`. Some readers find rose gendered. Alternative: coral `#C88870`. Confirm.

### Low impact (adjustable later)

- [ ] **Typeface:** Inter. Fallback: Nunito (softer but risk of drifting childish). Confirm Inter.
- [ ] **Check-in slider labels only at extremes:** "struggling" / "thriving". "Struggling" may feel heavy; alternative: "low" / "hard day". Confirm.
- [ ] **Body text one step larger than Material default** (17/15/13) for one-handed reading. Confirm.

### Infrastructure / launch

- [ ] **Supabase region** — pick based on primary user geography (Sydney / London / N. Virginia). Affects latency + data residency. Project already created, so this is locked unless we re-create.
- [ ] **Analytics provider** — PostHog (self-hostable, EU-friendly) or Firebase Analytics. Decide by Phase 4.
- [ ] **Onboarding goals taxonomy** — review [`docs/content/goals.md`](docs/content/goals.md) and flag any missing.
- [ ] **Final app name + logo** — founder sourcing externally. When ready, change `kAppName` in [`app/lib/app_constants.dart`](app/lib/app_constants.dart) and find-and-replace `{app_name}` across [`docs/copy_library.md`](docs/copy_library.md).
- [ ] **Territory-specific legal copy** (GDPR / AU Privacy Act / US) before Play Store submission.

## Immediate next actions (for whoever picks this up)

Backend live since 2026-05-03; auth + onboarding-persistence + check-in submit landed 2026-05-17. To pick this up:

1. Launch the AVD: `"%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd daily_tend_pixel -gpu host`, then from `app/` run `flutter run -d emulator-5554`.
2. **Wire the coach screen** ([`app/lib/screens/coach/coach_screen.dart`](app/lib/screens/coach/coach_screen.dart)) to call `generate_coach_reply` — POST `{ user_message }` with `Authorization: Bearer <user session JWT>`; render `reply` + `actions` from the response. Persist the chat history to `coach_messages` (the Edge Function already does this server-side; the screen just needs to read `coach_messages` to render the transcript on cold-start).
3. **Implement Drift offline cache** for check-ins per locked decision — replaces the direct Supabase write in [`CheckinRepository`](app/lib/data/checkin_repository.dart) with a write-through queue.
4. **Decide what stress/energy/sleep onboarding does** — write a first check-in, or remove those screens.
5. **Schedule `nightly_summariser`** via `pg_cron` (see [`supabase/README.md`](supabase/README.md)).
6. **Phases 4–7** of [`docs/plan.md`](docs/plan.md) — rules engine for daily plan, progress charts, reminders/widget, Health Connect.

## Gotchas

- **Original handover pack is read-only reference** — don't edit the docx/pptx files; all current decisions live in this doc and `docs/plan.md`.
- **`wellness_works_flash_drive_pack_v2/` is a duplicate of the handover pack** — same story, don't treat as current truth.
- **pg_cron** is called for in the migration but must also be enabled in the Supabase **dashboard** (Database → Extensions) — not just via `CREATE EXTENSION`.
- **The app name is a working title.** When the final brand lands, change `kAppName` in [`app/lib/app_constants.dart`](app/lib/app_constants.dart) and find-and-replace `{app_name}` in [`docs/copy_library.md`](docs/copy_library.md). The Dart package name `three_zones` and the (still-TBD) Android applicationId are deliberately neutral and should NOT change.
- **Tokens live in two places:** [`docs/design/tokens.json`](docs/design/tokens.json) is the source of truth; [`app/lib/theme/app_tokens.dart`](app/lib/theme/app_tokens.dart) mirrors it for Flutter. If you change one, change the other.

## Secrets — do NOT put on USB

When the project reaches a point of having real secrets, these must live ONLY in:
- Supabase secrets (`supabase secrets set ...`) — for server-side keys
- The developer's password manager — for dashboard passwords

Never commit, never email, never put on USB:
- OpenAI API keys
- Supabase `service_role` key
- Supabase database password
- Signing keys (when Play Store submission approaches)

The Supabase **publishable (anon) key** in [`app/lib/config/supabase_config.dart`](app/lib/config/supabase_config.dart) is safe to commit — that's what publishable keys are for. RLS is the actual access control.
