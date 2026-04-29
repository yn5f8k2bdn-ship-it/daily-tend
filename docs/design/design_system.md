# Wellness Works — Design System

_Working title. Visual system is brand-agnostic enough to survive a rename._

Platform: Flutter + Material 3, Android-first with Material You dynamic colour on Android 12+.
Voice/feel target: calm, warm, human, spacious. "Kitchen window in morning light."
Language: Australian/UK English.

---

## 1. Design principles

1. **Warm over clinical.** Favour muted earth tones, rounded forms and generous whitespace over cold whites and sharp edges. _Do_: a soft white-to-teal vertical gradient with a warm honey primary CTA. _Don't_: pure `#FFFFFF` and a saturated medical teal with no warmth in the palette.
2. **Ten seconds, one hand.** Every core flow must complete in a short burst with the thumb. _Do_: place primary actions within the lower 60% of the screen. _Don't_: put the submit button top-right out of thumb reach.
3. **Quiet contrast, loud legibility.** Text meets WCAG AA/AAA; decoration never does. _Do_: high-contrast body text on a soft surface. _Don't_: pastel-on-pastel headings for aesthetics.
4. **Zones are siblings, not rivals.** Self, Purpose and Loved Ones are equal in weight — no zone visually dominates. _Do_: three accents at matched chroma and lightness. _Don't_: make "Self" the brand primary and the others desaturated.
5. **Motion serves meaning.** Animation confirms state change; it never performs. _Do_: a 240 ms ease-out on a completed check-in. _Don't_: bouncy spring physics on a slider.

---

## 2. Palette

### 2.1 Fallback palette (light)

Used on Android <12, iOS, and anywhere dynamic colour is disabled.

**Neutrals**

| Token | Hex | Use |
|---|---|---|
| `neutral.bg` (surface) | `#FFFFFF` → `#54A4AE` | App background is a vertical gradient: white from the top through ~45%, transitioning to teal `#54A4AE` at the bottom. Wired in `app/lib/widgets/gradient_background.dart`. (Replaces the warm-linen `#F7F2EC` baseline 2026-04-29.) |
| `neutral.surface` | `#FFFBF5` | Cards, sheets |
| `neutral.surface_elevated` | `#FFFFFF` | Dialogs, top app bar on scroll |
| `neutral.on_surface` | `#1F1B16` | Primary body text |
| `neutral.on_surface_secondary` | `#5A534B` | Secondary text, metadata |
| `neutral.on_surface_tertiary` | `#8A8079` | Disabled, hint, captions |
| `neutral.divider` | `#E6DED3` | Hairlines, separators |
| `neutral.overlay` | `#1F1B1640` | Scrim (25% black over warm neutral) |

**Primary + Secondary**

| Token | Hex | Notes |
|---|---|---|
| `primary` | `#D9A04C` | Warm honey. Mid-century pair with the teal gradient bg. |
| `on_primary` | `#2E1F0E` | **Deep brown, not white.** White on `#D9A04C` is 2.3:1 (fails AA Large). Brown is 6.95:1 (AAA). |
| `primary_container` | `#FBE5C7` | Soft honey tint for selected chips, filled backgrounds. |
| `on_primary_container` | `#4A2F0E` | |
| `secondary` | `#2E6B73` | Deep teal. Sibling to the gradient teal `#54A4AE` — used for tonal containers and quieter affordances. |
| `on_secondary` | `#FFFFFF` | 6.1:1 contrast. |
| `secondary_container` | `#C2DBDD` | |
| `on_secondary_container` | `#0E2F33` | |

Honey-as-primary + deep-teal-as-secondary was chosen 2026-04-29 (replacing the earlier clay/sage pair) once the white-top, teal-bottom gradient bg landed. Clay against teal sat too close to complementary and clashed; honey is a classic mid-century pair with teal and keeps the warm-earth feel that the voice spec calls for.

**Semantic (gentle, not alarm-bell)**

| Token | Hex | Notes |
|---|---|---|
| `success` | `#5C8A5E` | Moss. Reuses primary family, not a traffic-light green. |
| `warning` | `#C99A3D` | Honey amber, not school-bus yellow. |
| `error` | `#B4544A` | Terracotta red, reads as concern, not emergency. |
| `info` | `#5E7E99` | Slate blue. |

**Three-Zone accents**

All three sit at roughly equal perceptual lightness (L\* ~60) and matched chroma so none dominates.

| Token | Hex | Zone | Feeling |
|---|---|---|---|
| `zone.self` | `#6B8FA8` | Self | Slate blue — introspection, quiet |
| `zone.purpose` | `#B8864A` | Purpose | Burnished ochre — effort, craft |
| `zone.loved_ones` | `#A8678A` | Loved Ones | Muted rose — warmth, connection |

| Token | Hex | Use |
|---|---|---|
| `zone.self_container` | `#D8E4EE` | Cards, chips for Self |
| `zone.purpose_container` | `#EEDFC7` | Cards, chips for Purpose |
| `zone.loved_ones_container` | `#EAD4DF` | Cards, chips for Loved Ones |

### 2.2 Fallback palette (dark)

Warm dark — avoids the blue-black "OLED void" which reads as clinical.

**Neutrals**

| Token | Hex |
|---|---|
| `neutral.bg` | `#1A1714` |
| `neutral.surface` | `#221E1A` |
| `neutral.surface_elevated` | `#2C2722` |
| `neutral.on_surface` | `#F1EAE0` |
| `neutral.on_surface_secondary` | `#BDB3A6` |
| `neutral.on_surface_tertiary` | `#877E72` |
| `neutral.divider` | `#38322C` |
| `neutral.overlay` | `#00000066` |

**Primary + Secondary**

| Token | Hex |
|---|---|
| `primary` | `#E8B86E` |
| `on_primary` | `#2E1F0E` |
| `primary_container` | `#5C4220` |
| `on_primary_container` | `#FBE5C7` |
| `secondary` | `#7FB5BC` |
| `on_secondary` | `#0E2F33` |
| `secondary_container` | `#1A4F58` |
| `on_secondary_container` | `#C2DBDD` |

**Semantic (dark)**

| Token | Hex |
|---|---|
| `success` | `#9AC49B` |
| `warning` | `#E6BE7A` |
| `error` | `#E09189` |
| `info` | `#9BB4C9` |

**Zone accents (dark)**

| Token | Hex |
|---|---|
| `zone.self` | `#A8C2D6` |
| `zone.purpose` | `#E2BA82` |
| `zone.loved_ones` | `#D9A7BC` |
| `zone.self_container` | `#2E404E` |
| `zone.purpose_container` | `#4E3B22` |
| `zone.loved_ones_container` | `#4A2E3C` |

### 2.3 Dynamic-colour mapping (Android 12+)

**Adopts wallpaper-derived scheme:**
- `primary`, `on_primary`, `primary_container`, `on_primary_container`
- `secondary`, `on_secondary`, `secondary_container`, `on_secondary_container`
- `tertiary` slot (not used in fallback — on dynamic it becomes a third neutral accent, not remapped to a zone)
- All `surface`, `surface_variant`, `background`, `outline`, `outline_variant` neutrals

**Stays frozen to brand tokens:**
- All three `zone.*` accents + containers — the Zones framework is a conceptual spine; if Self/Purpose/Loved Ones drifted toward the user's wallpaper they could collide, invert or merge, breaking the mental model.
- All `semantic.*` (success/warning/error/info) — safety-critical signals must not become a user-chosen magenta.
- Zone icon/illustration fills (see §9).

**Rationale:** users get the personalisation payoff (app feels "theirs") on chrome, navigation and primary actions, while the three Zones remain a stable, recognisable landmark across the app and across devices.

### 2.4 Contrast pairings (fallback, light)

| Pair | Ratio | Grade |
|---|---|---|
| `on_surface` on `bg` | 14.2:1 | AAA |
| `on_surface_secondary` on `bg` | 6.4:1 | AAA (large) / AA (body) |
| `on_surface_tertiary` on `bg` | 3.6:1 | AA large text / non-text only |
| `on_primary` (deep brown) on `primary` (honey) | 6.95:1 | AAA |
| `on_secondary` (white) on `secondary` (deep teal) | 6.1:1 | AA |
| `on_primary_container` on `primary_container` | 10.1:1 | AAA |
| `zone.self` on `bg` (text) | 4.6:1 | AA |
| `zone.purpose` on `bg` (text) | 4.5:1 | AA (borderline — use only on headings 18pt+/14pt bold, not body) |
| `zone.loved_ones` on `bg` (text) | 4.6:1 | AA |
| `error` on `bg` | 4.9:1 | AA |
| `success` on `bg` | 4.6:1 | AA |

Dark-mode ratios meet or exceed the same grades by construction; full matrix lives in `accessibility.md`.

---

## 3. Typography

**Typeface: Inter** (Google Fonts, OFL, ships with `google_fonts` package).

Chosen over Nunito (too rounded, reads childish in dense text), Plus Jakarta Sans (too geometric/brandy) and system Roboto (too default, no warmth). Inter is neutral-warm, highly legible at small sizes, has a real italic, supports tabular figures for streak counts, and includes an optical-size axis we will set for display sizes.

**Type scale** (Material 3 names, tuned for one-handed reading):

| Role | Font | Weight | Size (sp) | Line-height | Letter-spacing |
|---|---|---|---|---|---|
| `display.large` | Inter | 500 | 40 | 48 | -0.25 |
| `display.medium` | Inter | 500 | 32 | 40 | 0 |
| `headline.large` | Inter | 600 | 28 | 36 | 0 |
| `headline.medium` | Inter | 600 | 24 | 32 | 0 |
| `headline.small` | Inter | 600 | 20 | 28 | 0 |
| `title.large` | Inter | 600 | 18 | 26 | 0 |
| `title.medium` | Inter | 600 | 16 | 24 | 0.1 |
| `title.small` | Inter | 600 | 14 | 20 | 0.1 |
| `body.large` | Inter | 400 | 17 | 26 | 0.15 |
| `body.medium` | Inter | 400 | 15 | 22 | 0.2 |
| `body.small` | Inter | 400 | 13 | 18 | 0.25 |
| `label.large` | Inter | 600 | 15 | 20 | 0.1 |
| `label.medium` | Inter | 600 | 13 | 16 | 0.4 |
| `label.small` | Inter | 600 | 11 | 14 | 0.5 |

Body sizes run one step larger than Material defaults (17/15/13 instead of 16/14/12) because the audience skews busy/tired and reads one-handed.

**One-handed reading considerations**
- Never set body copy below 15sp.
- Never centre-align paragraphs >2 lines.
- Line length cap: ~60 characters; enforce with horizontal padding on phone widths.
- Tabular numerals (`fontFeatures: ['tnum']`) for any stat, streak, or time display.
- Respect user text scale up to 200% — verify at 130% and 200% (see `accessibility.md`).

---

## 4. Spacing + layout

**Base unit: 4 dp.** All spacing is a multiple of 4.

Canonical steps: `4, 8, 12, 16, 24, 32, 48, 64`.

| Step | Typical use |
|---|---|
| 4 | Icon-to-label gap, tight chip padding |
| 8 | Inside-component padding, small vertical rhythm |
| 12 | Between related items in a list |
| 16 | Standard screen edge padding; between unrelated paragraphs |
| 24 | Between sections within a screen |
| 32 | Between major page blocks |
| 48 | Hero spacing above a headline |
| 64 | Reserved for empty states and onboarding |

**Layout**
- Screen gutter: 16 dp (phone), 24 dp (≥600 dp wide).
- Card internal padding: 16 dp.
- Safe area: always respect system insets (status bar, nav gesture area, IME).
- **Minimum tap target: 48 × 48 dp.** Visual size can be smaller, but the hit region must be 48.
- Reserve a 16 dp gesture-safe strip above the system navigation bar — no primary actions sit inside it.
- Primary CTAs live in the bottom 40% of the screen where possible.

---

## 5. Corner radius + elevation

**Radius scale**

| Token | dp | Use |
|---|---|---|
| `radius.xs` | 8 | Chips, small tags |
| `radius.sm` | 12 | Text fields, small cards, buttons |
| `radius.md` | 16 | Standard cards, bottom sheets top |
| `radius.lg` | 24 | Hero cards, dialogs, full-bleed imagery |
| `radius.xl` | 32 | Illustrations, onboarding panels |
| `radius.full` | 9999 | Avatars, icon backgrounds, segmented controls |

Buttons use `radius.sm` (12 dp), not pill. Pills read gamified; 12 dp reads friendly-serious.

**Elevation — tonal, not shadow-heavy.**

Material 3 tonal elevation over shadow, because warm neutrals with drop shadows look muddy and "hospital waiting room."

| Level | Tonal tint (light) | Tonal tint (dark) | Shadow |
|---|---|---|---|
| 0 | `surface` base | `surface` base | none |
| 1 | +3% primary tint | +5% primary tint | none |
| 2 | +5% primary tint | +8% primary tint | y=1, blur=2, 8% |
| 3 | +8% primary tint | +11% primary tint | y=2, blur=6, 10% |
| 4 | +11% primary tint | +14% primary tint | y=4, blur=10, 12% |
| 5 | +14% primary tint | +17% primary tint | y=6, blur=14, 14% |

Use levels 0–2 for 95% of surfaces. Level 3 only for modals. Levels 4–5 reserved for FAB / menus.

---

## 6. Iconography

**Library: Material Symbols Rounded**, weight 400, optical size 24.

Rounded (not Outlined, not Sharp) because the rounded terminals echo the warm type and 12/16 dp radii. Outlined reads too utilitarian; Sharp reads clinical.

- Default size: 24 dp. Compact: 20 dp. Nav bar: 24 dp. Hero: 40 dp.
- Stroke treatment: use the `wght 400, FILL 0` variant by default; switch to `FILL 1` to indicate a selected state (e.g. active nav tab).
- Align icons to the 4 dp grid; leading icons sit 12 dp from the left edge of a row.
- Never colour an icon with a zone accent purely for decoration — icon colour follows semantic meaning (on-surface, on-primary, etc.) with the exception of the zone identifiers on zone cards.

---

## 7. Motion

**Durations** (ms): `short = 120`, `medium = 240`, `long = 360`, `xlong = 520`.
**Easings**: standard M3 — `emphasized`, `standard`, `standard-decelerate`, `standard-accelerate`.

Default bias: `medium` + `standard-decelerate` for entrances; `short` + `standard-accelerate` for exits. No spring/bounce physics anywhere.

**Patterns**
- Screen transition: shared-axis X, 240 ms, emphasized.
- Bottom sheet: slide + fade, 240 ms in, 200 ms out.
- Chip/button press: opacity dip to 92%, 120 ms, standard.
- Check-in submit confirmation: 360 ms tonal fill sweep behind the tick — the one deliberately "felt" moment in the app.
- Skeleton shimmer: 1200 ms loop, 8% amplitude, linear.

**Reduced motion** (OS accessibility setting on):
- Replace slides/shared-axis with pure cross-fades at 120 ms.
- Disable the check-in submit sweep — show a static tick with a 120 ms fade.
- Skeleton shimmer freezes to a static 92%-luminance block.
- Never disable motion entirely; confirmation needs _some_ state change.

---

## 8. Component patterns

### Buttons

- **Primary (filled):** `primary` fill, `on_primary` label, `radius.sm` (12 dp), 48 dp height, 24 dp horizontal padding, `label.large`. Used for the single strongest action on a screen.
- **Secondary (tonal):** `primary_container` fill, `on_primary_container` label. Used where you'd otherwise be tempted to use two primary buttons.
- **Text button:** no fill, `primary` label, 12 dp horizontal padding. For low-stakes inline actions ("Skip", "Not now").
- **Destructive:** `error` label on a transparent fill in menus/dialogs; only filled `error` on the final confirmation step of account deletion.

All buttons: focus ring is a 2 dp `outline` stroke offset 2 dp, never a glow.

### Cards

- **Content card:** `surface`, `radius.md`, elevation level 1, 16 dp internal padding. Default container for any scrollable list item.
- **Action card:** adds a trailing chevron and a single `label.large` title; entire surface is tappable with a 48 dp minimum height.
- **Zone-action card:** left edge gets a 4 dp `zone.*` colour bar; zone icon sits top-left at 24 dp; zone container tint (`zone.*_container`) applied at 40% opacity as a background wash. This is the only place zones get a "loud" treatment.

### Chips

- Height 32 dp, `radius.full`, 12 dp horizontal padding, `label.medium`.
- **Selectable:** unselected = `surface` with 1 dp `outline` stroke; selected = `primary_container` with `on_primary_container` label.
- **Filter:** same, plus a 16 dp leading check icon when selected.
- **Input** (e.g. tags on a reflection): adds a trailing 16 dp close icon with a 48 dp hit region.

### Check-in scale (1–5)

**Recommendation: segmented pills, not a classic slider.**

Rationale: the 1–5 scale is discrete and emotional, not continuous. A slider invites indecision ("is this a 3.4 or 3.6?") and is fiddly one-handed. Five evenly-spaced 56 × 48 dp pills in a row are thumb-sized, announce discrete values to screen readers as "1 of 5" etc., and give instant visual feedback via a tonal fill on the selected pill.

Layout: 5 pills across full width, 8 dp gaps, `radius.sm`, numeric label centred. Selected pill = `primary` fill, `on_primary` label; unselected = `surface` + 1 dp `outline`. Optional above-row captions ("struggling" / "thriving") in `label.small` at the extremes only — no label under every pill (too noisy).

### Segmented control (zone picker)

Three segments (Self / Purpose / Loved Ones), 48 dp tall, `radius.full` outer. Selected segment gets the zone's container fill (`zone.*_container`) and the zone icon fills (`FILL 1`); unselected segments show outlined icon + label in `on_surface_secondary`. All three segments are equal width — no default-selected "primary" zone.

### Text field, text area

- Outlined variant only (filled variant clashes with our warm surface).
- 1 dp `outline` resting, 2 dp `primary` focused.
- Floating label in `label.medium`, helper/error in `label.small` below.
- Text area for reflection note: minimum 3 lines visible, auto-grows to 8, then scrolls internally.
- Character counter appears only after 80% of limit reached (reduces anxiety).

### Dialog, bottom sheet

- **Dialog:** `surface_elevated`, `radius.lg` (24 dp), 24 dp internal padding, max width 320 dp, elevation level 3. Use sparingly — bottom sheets preferred on phone.
- **Bottom sheet (modal check-in):** `surface`, top `radius.lg`, 16 dp drag handle, 16 dp internal padding, respects IME inset. Max height 90% of viewport. Dismiss via drag-down or scrim tap. The daily check-in lives here.

### Snack bar, toast

- Snack bar only (Material pattern). `on_surface` background (dark in light mode, light in dark mode — inverted surface pattern). `radius.sm`, 48 dp min height, 4 s default duration, 7 s if an action is present.
- Never use for errors the user must act on — use an inline message instead.

### Empty state

- Centred illustration (~160 dp tall, see §10), `headline.small` title, `body.medium` description, one text or tonal button. Never a raw "No data" string.

### Progress indicators

- **Line chart** (mood over time): 2 dp stroke in `primary`, area fill at 12% opacity, dots only on the latest point and on tap. No gridlines; instead, 3 horizontal reference labels at right.
- **Donut** (weekly completion): 12 dp stroke, `primary` foreground, `primary_container` track. Centre shows `headline.medium` percentage in tabular numerals.
- **Skeleton:** `neutral.divider` blocks, `radius.sm`, with the reduced-motion-aware shimmer from §7.

### Navigation: bottom nav bar

**Recommended 4-tab structure:**

1. **Home** — today view, next check-in prompt, recent reflections
2. **Progress** — charts, streaks, zone-by-zone trends (check-in itself launches as a modal bottom sheet from Home or a FAB, not as its own tab; a check-in isn't a place, it's an action)
3. **Coach** — the AI/guided companion surface
4. **Settings** — account, notifications, privacy, exports

Rationale for four: five is the Material max but feels crowded; three hides Progress too deep. The check-in is the _verb_ of the app and lives as a persistent primary FAB on Home and Progress, not a tab — this prevents tab-count inflation and keeps the action reachable from the two surfaces where users think about it.

Nav bar: 80 dp tall including gesture inset, `surface` background, active item uses filled icon + `primary` label, inactive uses outlined icon + `on_surface_secondary` label. No badges except on Settings for critical account notices.

---

## 9. Zone visual identity

Zones must be scannable in 200 ms without reading the label, while remaining siblings (no tribal treatment).

**Differentiation stack (in order of strength):**

1. **Colour** — the three zone accents from §2.1.
2. **Icon** — a single consistent icon per zone, always from Material Symbols Rounded:
   - `zone.self` → `self_care` (or `person` if not available in set)
   - `zone.purpose` → `target` (or `flag` fallback)
   - `zone.loved_ones` → `diversity_3` (three-figure cluster)
3. **Shape-language accent** — each zone card's corner flourish uses a subtle motif, applied at 8% opacity so it reads as texture, not decoration:
   - Self: concentric arcs (inward focus)
   - Purpose: upward diagonal stripes (forward motion)
   - Loved Ones: interlocking circles (connection)
4. **Illustration palette** — onboarding illustrations for each zone pull from a 3-colour subset centred on that zone's accent (see §10).

Do _not_ differentiate by typography, font weight, or radius — those remain constant across zones.

---

## 10. Onboarding & empty-state illustrations

**Style direction:** flat 2-colour-plus-accent, hand-drawn-feeling vector with deliberate imperfect lines. Think woodcut-lite or risograph: warm, tactile, human. Neither corporate-flat nor 3D-render nor gradient-mesh.

**Rules:**
- Max 3 colours per illustration: one neutral, one zone accent, one supporting tint from the same zone's container.
- No faces with detailed features — use silhouettes or back-of-head / side-profile framing to keep identification open (respects diverse audience).
- No stock metaphors (light bulbs, rocket ships, trophies).
- Subjects are everyday and domestic: a kettle, a hand holding a phone, a person by a window, a shared meal, a walk.
- Line weight 1.5–2 dp, rounded caps, occasional hand-wobble in the stroke.
- No gradients, no drop shadows on illustrations.
- Composition breathes: subject occupies ~60% of the canvas, 40% negative space.

Commission a single illustrator for consistency; reject any output that looks like it could live in a SaaS marketing page.

---

## Decisions to sanity-check

1. ~~**Primary = sage / clay.**~~ **Resolved 2026-04-29: Primary = honey `#D9A04C`, secondary = deep teal `#2E6B73`, bg = white-to-teal gradient.** Founder iterated through clay-primary first, then trialed a teal gradient bg, which forced a repalette away from clay (complementary clash). Honey is the mid-century pair with teal; deep teal is a sibling to the bg. Three rejected alternates: deep-teal monochromatic (cooler than the locked voice spec), coral-pop (too loud for "calm wellness"), sage-as-secondary stayed (sat too close to gradient teal). All values single-source-of-truth in `app/lib/theme/app_tokens.dart` + `docs/design/tokens.json`.
2. **Zone accents.** Self = slate blue, Purpose = ochre, Loved Ones = rose. Confirm the emotional mapping — some users read rose as feminine-coded; swap Loved Ones to a muted coral `#C88870` if that's a concern.
3. **Check-in as modal, not tab.** Non-obvious; if early users can't find it, promote it to the nav bar and drop Coach to a Home entry point.
4. **Zones frozen against Material You.** Users who love dynamic colour may wish the whole app would adapt. We're holding the line on zones for coherence — worth user-testing.
5. **Inter over Nunito.** If user testing shows the app feels too "serious", Nunito at 500/700 is the fallback choice.
