# Material You dynamic colour spec

Scope: Android 12+ (API 31+). On earlier Android and iOS, the fallback palette from `design_system.md` applies unchanged.

Implementation path: `DynamicColorBuilder` (from `dynamic_color` Flutter package) wrapping our `ThemeData`. When the builder returns a non-null `ColorScheme`, we merge it with our frozen tokens; when null, we use the fallback scheme.

---

## 1. What adopts the dynamic scheme

The following M3 colour roles take their values from the user's wallpaper-derived scheme (both `ColorScheme.fromSeed`-style light and dark variants):

**Primary family**
- `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
- `inversePrimary`

**Secondary family**
- `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`

**Tertiary family**
- `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`
- Not used in the fallback scheme. On dynamic, we _do_ expose it and use it only for decorative accents (chart second-series, non-zone tag backgrounds). It is never used for zone identity.

**Surface + background + outline**
- `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`
- `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest` (M3 tonal surfaces)
- `background`, `onBackground`
- `outline`, `outlineVariant`
- `scrim`, `shadow`

Effect: the app's chrome, nav bar, primary buttons, filled chips, cards and backgrounds take on the user's wallpaper palette. The experience feels personalised and native-to-device.

---

## 2. What stays fixed (brand-frozen)

These never adopt the dynamic scheme. They load directly from `tokens.json`:

- **All three zone accents and their containers** — `zone.self`, `zone.purpose`, `zone.loved_ones` + `*_container` variants. Reason: the Zones are a conceptual spine across screens and across users. If they inherit from wallpaper they could converge (all three similar), invert (Self reading as rose, Loved Ones as blue — breaks mental model), or clash (a zone that was harmonious becomes the loudest element on the screen). A user who changed wallpaper mid-way through onboarding would effectively be shown different Zones.
- **All semantic colours** — `success`, `warning`, `error`, `info`. Safety-critical signalling cannot depend on user taste; an "error" recoloured by a lime wallpaper reads as confirmation.
- **Zone illustration fills** — any illustration accent that identifies a zone (the woodcut-style onboarding art from design_system §10) stays locked to the brand zone palette.
- **Check-in pill selected state** — uses `primary` (which _does_ adopt), but the zone indicator strip on zone-action cards stays fixed.

---

## 3. Light + dark dynamic behaviour

Both light and dark dynamic schemes are obtained (`dynamic_color` provides both). Flutter's `ThemeMode` (system / light / dark) selects between them.

**Blending rule for frozen tokens:**
- In dynamic light mode: frozen zone/semantic tokens use their fallback `light` hex values.
- In dynamic dark mode: frozen zone/semantic tokens use their fallback `dark` hex values.
- If the user's dynamic scheme pushes `surface` much warmer or cooler than the fallback bg, we trust it — no correction — because zone accents were chosen at matched L\*/chroma so they hold up against a range of neutrals.

**Edge case:** if the dynamic primary is very close in hue to a zone accent (e.g. wallpaper yields a sage primary, which sits near `zone.purpose` ochre? No — but near `zone.loved_ones`? possible for a dusty-rose wallpaper), we accept it. The zones remain distinguishable because of their container tints, icons and shape-language motifs (§9 of design_system.md). No programmatic hue-shifting — it produces worse results than trust.

**Contrast guard:** on every build, verify `on_surface` vs `surface` and `on_primary` vs `primary` meet ≥4.5:1. If either fails (rare, but some wallpapers produce low-contrast schemes), fall back to the branded palette for _that session_ and log a diagnostic. Never render below AA.

---

## 4. Testing checklist

Verify on these four wallpaper extremes in both light and dark mode:

- [ ] **Monochrome greyscale** — a black-and-white photo as wallpaper. Confirms zones still read (the dynamic scheme will be near-achromatic, and our frozen zones must still pop).
- [ ] **High-saturation single hue** — a vivid red, cobalt blue, or neon green wallpaper. Confirms no zone accent clashes with the derived primary, and that semantic `error` stays distinguishable from a red-derived `primary`.
- [ ] **Warm skin tone / sunset** — oranges and pinks. Confirms `zone.loved_ones` (rose) stays distinguishable from dynamic primary when both land in the warm-rose range; confirm via the shape-language motif and container tint.
- [ ] **Cool dark forest / night sky** — deep greens and blues. Confirms the dynamic dark surface doesn't fight the frozen zone accents and that body text maintains ≥4.5:1.

Each test: open Home, Progress, the check-in bottom sheet, and a zone-action card. Screenshot all four and compare zones side-by-side for scannability.
