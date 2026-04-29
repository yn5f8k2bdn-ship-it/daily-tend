# Copy library

Production-ready UI strings. Pull from here when building screens. If a string doesn't exist yet, write it in the voice spec (`voice.md`) and add it here.

Placeholders use `{curly_braces}` — e.g. `{first_name}`, `{habit_name}`.

The product name is referenced as `{app_name}` anywhere it appears in visible copy, so a rename doesn't require a rewrite.

---

## 1. Welcome / sign-in

**Headline.**
A quieter way to look after yourself.

**Subhead.**
Check in for a minute a day. Get one small thing to do across your health, your work, and the people you love.

**Primary button (Google).**
Continue with Google

**Secondary button (email).**
Continue with email

**Email screen — headline.**
What's your email?

**Email screen — helper.**
We'll send a sign-in link. No password to remember.

**Email screen — button.**
Send me the link

**Legal microcopy (below buttons).**
By continuing you agree to our Terms and Privacy Policy. {app_name} isn't medical advice.

**Check your inbox screen.**
We sent a link to {email}. Open it on this phone to sign in.

---

## 2. Onboarding (6 steps)

Every step has a **Skip** (text button, top right) and **Back** (top left, except step 1). Primary action label varies per step.

Global reassurance line (shown once, above step 1):
> Takes about a minute. You can change any of this later.

### Step 1 — Name

**Headline.** What should we call you?
**Subhead.** First name is fine. Nickname's fine too.
**Helper.** Used in check-ins and reminders. Only you see it.
**Input placeholder.** Your name
**Primary button.** Continue

### Step 2 — Main goal

**Headline.** What brought you here?
**Subhead.** Pick one. You can always switch.
**Helper.** We use this to shape what we suggest.
**Answer options.** See `content/goals.md`.
**Primary button.** Continue
**Skip label.** I'll decide later

### Step 3 — Stress baseline

**Headline.** Lately, how stressed do you feel?
**Subhead.** On most days, not today specifically.
**Helper.** This sets your starting point. It'll move over time.
**Scale.** 1–5 slider.
- 1 — Calm most of the time
- 2 — Mostly okay
- 3 — Up and down
- 4 — Tense a lot
- 5 — Running hot
**Primary button.** Continue

### Step 4 — Energy baseline

**Headline.** And your energy?
**Subhead.** Same idea — how it usually is, not today.
**Helper.** Low energy isn't a failure. It's information.
**Scale.** 1–5 slider.
- 1 — Running on empty
- 2 — Low
- 3 — Gets me through
- 4 — Mostly good
- 5 — Full tank
**Primary button.** Continue

### Step 5 — Sleep quality

**Headline.** How's your sleep these days?
**Subhead.** Rough guess is fine.
**Helper.** Sleep touches everything else. We'll keep an eye on it.
**Scale.** 1–5 slider.
- 1 — Broken most nights
- 2 — Not great
- 3 — Mixed
- 4 — Usually okay
- 5 — Solid
**Primary button.** Continue

### Step 6 — Coaching tone

**Headline.** How should we talk to you?
**Subhead.** Pick the one that feels right today. You can change it any time in Settings.
**Helper.** All four are kind. They just land differently.
**Answer options (radio).**
- **Calm.** Softer, slower, leaves space. "A couple of quiet days is fine."
- **Practical.** Straight to the useful thing. "Pick one: walk, water, early bed."
- **Tough love.** Honest, a little dry. Never cruel. "Don't overhaul anything. Just sleep earlier."
- **Reflective.** Asks a short question back. "What do you think tipped it?"
**Primary button.** Finish setup
**Finish screen (brief, auto-advances).** You're in. Let's start with a quick check-in.

---

## 3. Daily check-in

**Intro (top of screen).**
A minute, tops. Be honest — nobody else sees this.

### Sliders (all 1–5)

Each slider shows a short label under the number while the user is dragging.

**Mood.**
- Prompt: How's your mood right now?
- Scale labels:
  1. Low
  2. Flat
  3. Okay
  4. Good
  5. Really good

**Stress.**
- Prompt: Stress level today?
- Scale labels:
  1. None
  2. Light
  3. Noticeable
  4. Heavy
  5. Overloaded

**Energy.**
- Prompt: Energy today?
- Scale labels:
  1. Empty
  2. Low
  3. Enough
  4. Good
  5. Firing

**Sleep (last night).**
- Prompt: Last night's sleep?
- Scale labels:
  1. Broken
  2. Poor
  3. Mixed
  4. Good
  5. Solid

### Habit tick

**Prompt.** Did you do your habit yesterday — {habit_name}?
**Options.** Yes / No / Skipped on purpose
**Helper (below options).** "Skipped on purpose" doesn't count against you. Rest is part of it.

### Three Zones focus question

**Prompt.** Where does your energy need to go today?
**Subhead.** One zone. We'll build the day around it.
**Options.**
- **Self** — health, headspace, rest
- **Purpose** — work, goals, what matters
- **Loved Ones** — family, partner, friends

### Reflection note

**Prompt.** Anything you want to note?
**Subhead.** Optional. One line is fine.
**Placeholder.** e.g. "Short on sleep, big meeting at 10."

### Submit

**Button.** Save check-in
**Success state — headline.** Done.
**Success state — body.** Your day's on the home screen. No need to hurry.
**Success state — button.** See today

---

## 4. Home dashboard

### Greeting variants

Randomised within each band. Never the same line two days running.

**Morning (first visit of the day, before 11am).**
- Morning, {first_name}.
- Hey {first_name}. Easy start.
- Morning. One thing at a time today.
- {first_name} — here we go.

**Midday (11am–5pm).**
- Afternoon, {first_name}.
- Halfway through. How are you doing?
- Still here. Good.

**Evening (after 5pm).**
- Evening, {first_name}.
- Nearly done for the day.
- Long one? Short one? Either way — you're here.

**Returning same day (not first visit).**
- Back again.
- Quick one?
- Still with us.

### Today's focus card

**Heading.** Today's focus
**Body template.** `{zone_label} · {day_type_label}`
**day_type_label values.**
- recovery → Recovery day
- gentle → Gentle day
- momentum → Momentum day
- balanced → Balanced day
**Footer line (example).** Pick one thing below. Ignore the rest.

### Zone action cards (three, one per zone)

**Card heading template.** `{zone_label}`
**Body.** The action string from `content/actions.md`.
**CTA.** Mark as done
**After marked.** Nice. That's enough for this zone today.

### No check-in yet today — empty state

**Headline.** No check-in yet today.
**Body.** One minute and your day lines up.
**Primary button.** Start check-in

### Already checked in, mid-day

**Headline.** You're set for today.
**Body.** Come back tonight for a short reflection if you want.

---

## 5. AI coach

### Initial empty state

**Headline.** Talk to the coach.
**Body.** Ask anything — a rough morning, a stuck feeling, what to do about tonight. Short answers, no advice you didn't ask for.
**Example starter prompts (tappable chips).**
- I had a rough day.
- I can't get started.
- Help me wind down.
- I'm overthinking something.
- What should I do in 10 minutes?
- I feel flat.

### Thinking state

- Thinking…
- One sec.
- Reading that back to you…

(Random of the three, not a spinner label loop — pick one per turn.)

### Error state

**Headline.** Couldn't reach the coach.
**Body.** Not your fault. Try again in a moment, or check in instead — that still works offline.
**Button.** Try again

### Tone disclaimer (persistent footer on coach screen, small)

Coach isn't medical advice. If something's urgent, talk to a real person.

---

## 6. Progress

### Empty state (first week)

**Headline.** Not enough data yet.
**Body.** Check in for a few days and this page starts making sense.

### Weekly reflection framings (headline per day_type mix)

Shown at the top of the weekly summary, keyed to the dominant day_type of the week.

- **Mostly recovery week.** "A slow week. Those count too."
- **Mostly gentle week.** "A quiet one. Nothing wrong with that."
- **Mostly momentum week.** "A strong week. Worth noticing — and worth not burning on."
- **Mostly balanced week.** "A steady week. That's the hard one to actually have."

Body under each (shared template):
> You checked in {n} days, moved on {zone_name} most, and rated your sleep {sleep_avg}/5. Small pattern to watch: {insight}.

### Zone-balance donut captions

- All three moved this week: "Even spread. That's rarer than it sounds."
- One zone dominant: "{zone_name} got most of your energy. Worth asking if that's by choice."
- One zone missing: "Light on {zone_name} this week. Not a problem — just a note."

---

## 7. Settings

### Section labels

- Account
- Coaching
- Reminders
- Privacy
- About

### Coaching tone control

**Label.** Coaching tone
**Helper.** How the coach talks to you. Change any time.

### Reminder time control

**Label.** Daily reminder
**Helper.** We'll nudge you once. No repeats.
**Sub-control.** Time picker. Default: 8:00am.

### Privacy mode toggle

**Label.** Private mode
**Helper.** Hides your notes and reflections when someone else picks up your phone. Unlock with your device passcode.

### Logout confirm

**Headline.** Log out?
**Body.** You can sign back in any time. Your data stays.
**Primary button.** Log out
**Secondary button.** Stay signed in

### Delete account confirm

**Headline.** Delete your account?
**Body.** This removes your check-ins, notes, and coaching history. We can't get it back.
**Confirmation input.** Type DELETE to confirm
**Primary button.** Delete account
**Secondary button.** Cancel

---

## 8. Notifications

Push notifications. One line each. No emoji. No "!".

### Smart daily reminder (5 variants, rotated)

1. Morning. One minute when you're ready.
2. Quick check-in?
3. How's today sitting?
4. A minute on yourself.
5. Small check. No pressure.

### Missed-day gentle nudge (after 2 days no check-in)

- Been a couple of days. No catch-up needed — just say hi.
- Come back when you can. Today's fine.
- No streak to worry about. Check in if you've got a minute.

### Weekly reflection ready

- Your week's ready to look at. Takes about 30 seconds.
- Short reflection's ready when you are.

### Habit nudge (optional, only if user opted in)

- Small one — {habit_name}?
- {habit_name}. Two minutes, done.

---

## 9. Empty states (generic)

### Generic template

**Headline.** Nothing here yet.
**Body.** {context_specific_line}
**CTA.** {primary_action}

### Progress — first-time

See Progress section above.

### History — no check-ins logged

**Headline.** No history yet.
**Body.** Your first check-in will show up here.

### Coach — no conversations

Covered in AI coach section.

### Habits — none selected

**Headline.** No habit picked yet.
**Body.** Start with one. Small is fine — actually, small is better.
**Button.** Choose a habit

---

## 10. Error messages

All errors follow: **what happened · what to do**. Never blame the user. No codes.

### Network

**Headline.** No connection.
**Body.** Check your Wi-Fi or data, then try again. Your check-in is still saved on this phone.
**Button.** Try again

### Auth failed (sign-in link expired)

**Headline.** That link expired.
**Body.** They only last 15 minutes. We can send a new one.
**Button.** Send a new link

### Coach unavailable

**Headline.** Coach is offline.
**Body.** Usually sorts itself in a minute. Your check-ins still work.
**Button.** Try again

### Check-in save failed

**Headline.** Couldn't save that.
**Body.** Keep the screen open — we'll retry when the connection's back. Nothing's lost.

### Generic fallback

**Headline.** Something went wrong on our end.
**Body.** Give it a moment, then try again. If it keeps happening, tell us in Settings → About.

---

## 11. Legal / disclaimer microcopy

### Medical disclaimer — onboarding (shown once, before first check-in)

{app_name} is a wellness companion, not medical advice. If something feels serious — your mood, your health, someone else's — talk to a real person. A doctor, a friend, a helpline. We'll still be here after.

**Button.** Got it

### Medical disclaimer — settings (static text)

**Heading.** About the coach
**Body.** The coach uses AI to reflect what you share and suggest small things. It isn't a therapist, a doctor, or a diagnosis. If you're in crisis, contact a local support line.

### Privacy note — AI data use (shown near coach screen, tappable "how this works" link)

**Heading.** How the coach uses your data
**Body.** Your messages and check-ins are sent to our AI provider so the coach can respond. They aren't used to train anyone's model. You can delete your coaching history any time in Settings.

### Privacy note — check-in data

**Heading.** Your check-ins
**Body.** Stored on your device and in your private account. Nobody else sees them. You can export or delete everything from Settings.

---

## 12. Cross-references

- Voice principles: `voice.md`
- Goal picker options: `content/goals.md`
- Habit library: `content/habits.md`
- Daily action library (by day_type × zone): `content/actions.md`
