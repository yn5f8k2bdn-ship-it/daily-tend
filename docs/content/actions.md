# Daily action library

The rules engine picks one action per zone per day, keyed to the day_type. Each combination has 5 options so the engine can rotate and the user doesn't see the same line twice in a week.

**Day types.**
- `recovery` — the user is depleted. Gentle, low-demand, restorative.
- `gentle` — not bad, not great. Kind, low-effort, keep the momentum small.
- `momentum` — user has capacity. Propulsive but not manic.
- `balanced` — a normal good day. Steady, unglamorous, good moves.

**Zones.** `self`, `purpose`, `loved_ones`.

**Counts.**
- 4 day_types × 3 zones × 5 actions = **60 zone actions**
- 4 day_types × 5 recovery-evening actions = **20 evening actions**
- **Total: 80 entries**

Every action is specific. No "do something kind". No "take a moment". If a line could be on a coffee mug, it's been rewritten.

---

## Recovery day

The job today is to stop the bleed. Small, warm, low-demand.

### Self (recovery)
1. Go to bed 30 minutes earlier tonight.
2. Walk for 10 minutes, no phone.
3. Drink a big glass of water right now.
4. Skip the third coffee.
5. Do nothing for 10 minutes and notice what you feel.

### Purpose (recovery)
1. Move one meeting. Not all of them — one.
2. Write down the three things you're not doing today. Close the list.
3. Do the easiest thing on your list, then stop for 20 minutes.
4. Send the "I'll get to this tomorrow" message you've been avoiding.
5. Protect one hour for nothing. Put it in the calendar.

### Loved Ones (recovery)
1. Text one person: "No need to reply — just thinking of you."
2. Tell someone at home you're running low today. Let them help.
3. Sit with someone for 10 minutes without your phone.
4. Cancel a social thing you're dreading. Reschedule it kindly.
5. Say "thank you" properly to one person today.

### Evening (recovery)
1. Phone out of the bedroom tonight.
2. Warm shower, dim lights, in bed by 10.
3. Write one line: what took the most out of you today?
4. No screens for the last 30 minutes before bed.
5. Something easy for dinner. Tonight isn't for cooking.

---

## Gentle day

Nothing's wrong. Nothing's spectacular. Small moves that don't cost much.

### Self (gentle)
1. Take a 15-minute walk at some point today.
2. Eat lunch away from your desk.
3. Stretch for 5 minutes mid-afternoon.
4. Swap one scroll session for standing outside.
5. Drink water before your next coffee.

### Purpose (gentle)
1. Tidy the top of your inbox. Ten minutes, no more.
2. Pick the smallest task on your list and finish it.
3. Write tomorrow's top 3 before you log off.
4. Close 10 tabs you're never going back to.
5. Message one person to unblock one thing.

### Loved Ones (gentle)
1. Send a two-line text to someone you haven't spoken to this week.
2. Ask your partner, kid or flatmate: "How's your day actually going?"
3. Share a photo or a song with someone who'd like it.
4. Eat one meal today with someone, no phones on the table.
5. Leave a voice note instead of a text. Takes less time, lands better.

### Evening (gentle)
1. Finish the day 15 minutes earlier than usual.
2. Read for 10 minutes before picking up the phone.
3. Put tomorrow's clothes out. Future-you will thank you.
4. Note one small thing that went right today.
5. Stretch for 5 minutes in bed.

---

## Momentum day

You've got capacity. Use some of it — don't set it all on fire.

### Self (momentum)
1. Work out for 30 minutes. Any kind you actually like.
2. Cook a proper meal from scratch.
3. Get outside for half an hour at lunch.
4. Go to bed at the time you keep saying you will.
5. Take the stairs today. Every time.

### Purpose (momentum)
1. Do a 45-minute deep work block. Phone in another room.
2. Finish the thing you've been 80% done with.
3. Send the message you've been drafting in your head.
4. Pick the hardest thing on your list and start it first.
5. Block out time this week for the project you keep postponing.

### Loved Ones (momentum)
1. Call someone for a proper 15 minutes, not a text.
2. Plan a proper evening with someone you love this week.
3. Write a short note to someone who'd be surprised to get one.
4. Cook for someone tonight, even if it's simple.
5. Arrange a weekend thing — a walk, a coffee, a meal.

### Evening (momentum)
1. Write down the win today. Specific. One line.
2. Protect tomorrow morning — no meetings before 10 if you can.
3. Pack your bag tonight so the morning is quiet.
4. Ten minutes of reading instead of scrolling.
5. In bed by 10:30. You earned the sleep.

---

## Balanced day

A regular good day. These are the moves that add up over a year.

### Self (balanced)
1. 20-minute walk, somewhere green if you can.
2. Three proper meals today. That's the whole ask.
3. Finish work at a sensible time.
4. Stretch for 10 minutes before bed.
5. One piece of fruit. Seriously.

### Purpose (balanced)
1. One focused hour on your top priority, uninterrupted.
2. Respond to the messages you've been avoiding. Keep it brief.
3. Review your week. Ten minutes, no more.
4. Say no to one thing that doesn't matter.
5. Leave work at a reasonable time and don't check email tonight.

### Loved Ones (balanced)
1. Dinner without phones at the table tonight.
2. Ask a real question and actually listen to the answer.
3. Text a friend — "thinking of you" counts as a full message.
4. Spend 20 minutes with family without multitasking.
5. Thank someone for something small they did recently.

### Evening (balanced)
1. Wind down 30 minutes before you want to be asleep.
2. One glass of water before bed.
3. Close the tabs. Close the loops. Close the laptop.
4. Note one thing tomorrow-you will be glad present-you did.
5. Lights down by 10, phone face-down.

---

## Engine notes

- Actions rotate per zone per day_type — don't serve the same one two weeks in a row.
- When a user has picked a specific habit (`content/habits.md`), that habit outranks the action pool for their current focus zone.
- Recovery-day language should never demand. "If you can" is a valid softener there and only there.
- Momentum-day language can be direct ("do", "finish", "send") but never hype ("crush", "smash", "unleash").

## Decisions to eyeball

- We deliberately didn't write any action that requires buying or installing something (no "try the 4-7-8 breathing technique", no app-in-app recommendations). Confirm this stays the rule.
- We chose not to include alcohol-related actions ("skip the wine tonight") even though they'd fit recovery-day self — the user brief says we're low-pressure and non-preachy. Flag for the user: do we ever want to touch alcohol, or leave it alone entirely?
- Momentum-day actions sit at what feels like a real threshold (30-min workout, 45-min deep work). If the target audience is more depleted than we think, these may need to be dialled down. Worth a usability check after launch.
