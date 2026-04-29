# Goals

The onboarding "main goals" picker. **Multi-select: 1–3 goals per user**, changeable later in Settings. _Founder change 2026-04-29 — was originally single-select; widened so the rules engine can blend two or three zone affinities (e.g. "More energy" + "Show up for family" weights both Self and Loved Ones)._

**Schema implication:** `profiles.goal text` (single value) needs to become an array — either `profiles.goals text[]`, a separate `profile_goals` join table, or a JSONB array. Decide before Phase 1 persistence wiring.

Used by the rules engine to bias which zones get more airtime and which habits surface first. `zone_affinity` is a list — an array of one or two zones where this goal most clearly lives.

Zones: `self`, `purpose`, `loved_ones`.

Every option is written to sound like something a real person would say out loud. No marketing copy, no clinical language. If an option feels like a slogan, it's been rewritten.

---

## Options (9)

### 1. Have more energy day-to-day
- **Label.** More energy
- **Subtitle.** Not exhausted by 3pm.
- **zone_affinity.** [self]

### 2. Feel less overwhelmed
- **Label.** Less overwhelmed
- **Subtitle.** Fewer days running on fumes.
- **zone_affinity.** [self, purpose]

### 3. Sleep better
- **Label.** Sleep better
- **Subtitle.** Fall asleep easier, wake up okay.
- **zone_affinity.** [self]

### 4. Build consistent routines
- **Label.** Be more consistent
- **Subtitle.** Small things, most days.
- **zone_affinity.** [self]

### 5. Show up better for my family
- **Label.** Show up for family
- **Subtitle.** Be more present at home.
- **zone_affinity.** [loved_ones]

### 6. Reconnect with people I care about
- **Label.** Stay in touch
- **Subtitle.** Less slipping out of contact.
- **zone_affinity.** [loved_ones]

### 7. Get moving again
- **Label.** Move more
- **Subtitle.** Walks count. Small counts.
- **zone_affinity.** [self]

### 8. Get unstuck at work
- **Label.** Get unstuck
- **Subtitle.** Stop spinning, start finishing.
- **zone_affinity.** [purpose]

### 9. Work out what actually matters
- **Label.** Find direction
- **Subtitle.** Quieter head, clearer priorities.
- **zone_affinity.** [purpose, self]

---

## Notes on coverage

- **Busy adults** are covered by 1, 2, 3, 4, 7.
- **Parents** are covered by 5, 6, and often 2.
- **Stuck / burnt-out** is covered by 2, 8, 9.
- **Inconsistent** is directly addressed by 4.

No option reads as "optimise your life" or "become your best self" — both are off-voice.

## Decisions to eyeball

- We deliberately don't include weight loss, body composition, or fitness performance goals. The brief says we're not for athletes or biohackers, and including those would pull the app toward competitor territory (Fabulous, etc.). Flag: confirm with user before launch.
- We don't include a "mental health" goal. Reason: we're not a therapy app and don't want to set that expectation. "Feel less overwhelmed" is the closest we go.
- We landed on 9 options (brief asked for 8–10). Adding a 10th risks dilution; removing one would leave a persona under-covered.
