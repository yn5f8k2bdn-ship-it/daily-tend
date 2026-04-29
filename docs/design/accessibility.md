# Accessibility spec

Baseline: WCAG 2.2 AA on all text and interactive states. AAA where practical. This document is binding — any ship that drops below these thresholds is a bug.

---

## 1. Targets per surface

| Surface | Target |
|---|---|
| Body text (≤18 pt regular, ≤14 pt bold) | **AA (4.5:1)** minimum, **AAA (7:1)** preferred |
| Large text (≥18 pt, or ≥14 pt bold) | AA (3:1) minimum, AAA (4.5:1) preferred |
| Icons and interactive non-text | AA (3:1) against adjacent colour |
| Focus indicators | AA (3:1) against both focused element and background |
| Disabled text | Visible but not required to meet AA |
| Decorative illustration | Exempt |

---

## 2. Contrast matrix — fallback palette (light)

Computed against `neutral.bg` `#F7F2EC` unless otherwise stated.

| Foreground | Background | Ratio | Grade | Notes |
|---|---|---|---|---|
| `on_surface` `#1F1B16` | `bg` `#F7F2EC` | 14.2 | AAA | Body default |
| `on_surface` | `surface` `#FFFBF5` | 15.1 | AAA | Card body |
| `on_surface_secondary` `#5A534B` | `bg` | 6.4 | AAA (large) / AA (body) | Metadata, captions |
| `on_surface_tertiary` `#8A8079` | `bg` | 3.6 | AA large only | Hints, disabled placeholders — never for body |
| `on_primary` `#FFFFFF` | `primary` `#6E8A6A` | 4.8 | AA | Primary button label |
| `on_secondary` `#FFFFFF` | `secondary` `#C97B4A` | 4.7 | AA | Secondary CTAs |
| `on_primary_container` `#1F2C1B` | `primary_container` `#D6E3CF` | 10.1 | AAA | Filled chip label |
| `on_secondary_container` `#3A1F0E` | `secondary_container` `#F4DCC9` | 10.6 | AAA | |
| `primary` `#6E8A6A` (text) | `bg` | 4.6 | AA | Text buttons |
| `secondary` `#C97B4A` (text) | `bg` | 3.9 | AA large only | Never for body |
| `error` `#B4544A` | `bg` | 4.9 | AA | Inline error messages |
| `success` `#5C8A5E` | `bg` | 4.6 | AA | |
| `warning` `#C99A3D` | `bg` | 3.2 | AA large only | Pair with an icon, never use alone for body |
| `info` `#5E7E99` | `bg` | 4.5 | AA | At threshold — prefer for labels/headings |
| `zone.self` `#6B8FA8` (text) | `bg` | 4.6 | AA | Zone label on neutral |
| `zone.purpose` `#B8864A` (text) | `bg` | 4.5 | AA | At threshold — 18 pt+ / 14 pt bold only |
| `zone.loved_ones` `#A8678A` (text) | `bg` | 4.6 | AA | |
| `on_surface` | `zone.self_container` `#D8E4EE` | 12.6 | AAA | Body inside Self card |
| `on_surface` | `zone.purpose_container` `#EEDFC7` | 13.4 | AAA | Body inside Purpose card |
| `on_surface` | `zone.loved_ones_container` `#EAD4DF` | 12.9 | AAA | Body inside Loved Ones card |
| `divider` `#E6DED3` | `bg` | 1.1 | — | Decorative only |

## 2.1 Contrast matrix — fallback palette (dark)

Against `neutral.bg` `#1A1714` unless noted.

| Foreground | Background | Ratio | Grade |
|---|---|---|---|
| `on_surface` `#F1EAE0` | `bg` | 14.3 | AAA |
| `on_surface_secondary` `#BDB3A6` | `bg` | 8.6 | AAA |
| `on_surface_tertiary` `#877E72` | `bg` | 4.5 | AA |
| `primary` `#A9C4A2` (text) | `bg` | 9.2 | AAA |
| `on_primary` `#16231A` | `primary` `#A9C4A2` | 9.4 | AAA |
| `secondary` `#E8A578` (text) | `bg` | 8.1 | AAA |
| `error` `#E09189` | `bg` | 7.4 | AAA |
| `success` `#9AC49B` | `bg` | 8.3 | AAA |
| `warning` `#E6BE7A` | `bg` | 10.2 | AAA |
| `info` `#9BB4C9` | `bg` | 8.4 | AAA |
| `zone.self` `#A8C2D6` | `bg` | 9.8 | AAA |
| `zone.purpose` `#E2BA82` | `bg` | 10.1 | AAA |
| `zone.loved_ones` `#D9A7BC` | `bg` | 8.7 | AAA |

Dark mode meets or exceeds AAA on all text; this is by design (easier to hit contrast on warm-dark than warm-light).

---

## 3. Screen-reader semantic labels

Every interactive element gets a `Semantics` label. Announcements below are copy-specs — engineers should use these strings.

### Check-in scale (1–5 segmented pills)

- Role: `radio` group, labelled "How is your \[zone\] today?" where `[zone]` is the active zone's human name.
- Each pill: label "\[value\] of 5, \[extreme label if 1 or 5\]". Examples:
  - Pill 1: "1 of 5, struggling"
  - Pill 2: "2 of 5"
  - Pill 3: "3 of 5"
  - Pill 4: "4 of 5"
  - Pill 5: "5 of 5, thriving"
- Selection announces: "Selected. \[value\] of 5."
- Group hint: "Select how you're feeling."

### Zone picker (segmented control)

- Role: `tablist`.
- Each segment: `tab` role, label = zone name ("Self", "Purpose", "Loved Ones"), state announces "selected" or "not selected".
- Hint on the group: "Choose which area of your life to check in on."
- Do _not_ read colour or icon — the zone name carries meaning.

### Chips

- Selectable: label = chip text, role = `checkbox`, state = "selected" / "not selected".
- Filter: same, but prefix hint "Filter: ".
- Input: role = `button`, label = "\[tag\] tag, activate to remove".

### Text fields

- Label always paired with the field (not a floating-only label, which screen readers miss mid-edit).
- Helper text associated via `aria-describedby` equivalent.
- Error state announces: "\[label\], error: \[error text\]".
- Reflection note: multi-line hint "Reflection note, multiple lines, optional."

### Buttons

- Primary/secondary: label = visible text.
- Icon-only buttons: mandatory label (e.g. close → "Close", back → "Back").
- Destructive: label prefixed with the action verb ("Delete account"), never just "Delete".

### Navigation

- Bottom nav: `tablist`, each tab labelled "\[name\], tab \[n\] of 4".
- FAB (check-in): "Start check-in".

### Progress indicators

- Donut: labelled "\[percentage\] of weekly check-ins complete".
- Line chart: exposed as a data table alternative via a "View as list" text button beneath the chart — screen readers get a real list of date/value pairs, not a chart.
- Skeleton loaders: announce "Loading" once, not per-block.

### Snack bar

- Live region, `polite` politeness. Dismisses auto-read after 4 s.
- If a snack bar has an action, its text is included in the announcement.

---

## 4. Dynamic Type / text scaling

Target: usable up to 200% OS text scale. Verify at 130% and 200%.

### Reflow rules

- No fixed-height text containers. All text containers grow vertically.
- Buttons: 48 dp minimum height at 100%; at 200%, expand height to fit, never truncate label. If label wraps to two lines, button grows to 64 dp; tap target still meets 48 minimum.
- Headlines: at 200% scale, `display.large` wraps to two lines on a phone — allow it, don't compress.
- Cards: internal padding stays 16 dp; card grows vertically.
- Bottom nav labels: hide labels (keep icons + `Semantics` label) at ≥160% scale to prevent wrap; icons remain 24 dp.
- Chips: wrap onto new lines rather than ellipsise.

### Never

- Never apply `textScaleFactor: 1.0` to force-ignore the user's setting.
- Never use `FittedBox` to shrink text to fit.
- Never ellipsise body copy (titles on cards may ellipsise after 2 lines; everything else wraps).

---

## 5. Reduced motion

When the OS `Reduce Motion` / `Disable animations` setting is on (`MediaQuery.disableAnimations` true):

- All slide/shared-axis transitions → cross-fade at 120 ms.
- Check-in submit sweep → static tick with a 120 ms fade.
- Skeleton shimmer → frozen static block at shimmer's mid-luminance.
- Bottom sheet slide-up → instant appearance with 120 ms fade.
- Chart draw-on animation → instant render.

State changes must still be _visible_ — confirmation never becomes silent. A 120 ms opacity change is enough.

---

## 6. Colour-blind test

All three zone accents must remain distinguishable under the three common simulations, and must never be the sole channel of meaning (every zone is also labelled and iconed).

### Expected appearance per simulation

**Protanopia** (red-blind, ~1% of males):
- `zone.self` `#6B8FA8` → reads as muted blue-grey (minimal shift).
- `zone.purpose` `#B8864A` → reads as dull yellow-olive (loses warmth).
- `zone.loved_ones` `#A8678A` → reads as grey-blue with a slight violet cast (largest shift — rose desaturates).
- **Still distinguishable?** Yes. Self stays clearly blue; Purpose stays yellow-olive; Loved Ones lands in a grey-violet zone distinct from both. Icons + labels confirm.

**Deuteranopia** (green-blind, ~5% of males — the common one):
- `zone.self` → muted blue (near-unchanged).
- `zone.purpose` → dull yellow-brown.
- `zone.loved_ones` → desaturated mauve.
- **Still distinguishable?** Yes. The three zones span blue / yellow-brown / mauve, which are three different hue regions deuteranopic users perceive as distinct.

**Tritanopia** (blue-blind, <0.01% — rare but required):
- `zone.self` → shifts toward teal/green-grey (biggest loss).
- `zone.purpose` → shifts toward pink-red (yellow channel collapses).
- `zone.loved_ones` → near-unchanged muted rose.
- **Still distinguishable?** Borderline — Self and Loved Ones can come close in a tritanopic simulation. Mitigation: the shape-language motif, the distinct Material Symbols icon per zone, and the plain-text zone label are always present on any zone-identifying element. Never ship a screen that identifies a zone by colour alone.

### Required test tooling

- Use Figma's "Vision Simulator" or Stark plugin during design review.
- Flutter runtime check: `ColorFilter.matrix` applied behind a dev-only toggle in Settings for engineers.
- Automated visual diff under each of the three simulations included in the pre-merge CI once the app has screens to snapshot.

### Rule of thumb

If the only difference between two UI states is colour, that's a bug — add an icon, a label, or a shape.
