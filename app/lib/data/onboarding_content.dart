/// Static content for the onboarding flow + check-in.
///
/// Mirrors `docs/content/goals.md` and the scale labels in
/// `docs/copy_library.md` §3. Keep these two sources in sync.
class Goal {
  const Goal({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.zoneAffinity,
  });

  final String id;
  final String label;
  final String subtitle;
  final List<String> zoneAffinity; // 'self' / 'purpose' / 'loved_ones'
}

const List<Goal> kGoals = [
  Goal(
    id: 'more_energy',
    label: 'More energy',
    subtitle: 'Not exhausted by 3pm.',
    zoneAffinity: ['self'],
  ),
  Goal(
    id: 'less_overwhelmed',
    label: 'Less overwhelmed',
    subtitle: 'Fewer days running on fumes.',
    zoneAffinity: ['self', 'purpose'],
  ),
  Goal(
    id: 'sleep_better',
    label: 'Sleep better',
    subtitle: 'Fall asleep easier, wake up okay.',
    zoneAffinity: ['self'],
  ),
  Goal(
    id: 'be_more_consistent',
    label: 'Be more consistent',
    subtitle: 'Small things, most days.',
    zoneAffinity: ['self'],
  ),
  Goal(
    id: 'show_up_for_family',
    label: 'Show up for family',
    subtitle: 'Be more present at home.',
    zoneAffinity: ['loved_ones'],
  ),
  Goal(
    id: 'stay_in_touch',
    label: 'Stay in touch',
    subtitle: 'Less slipping out of contact.',
    zoneAffinity: ['loved_ones'],
  ),
  Goal(
    id: 'move_more',
    label: 'Move more',
    subtitle: 'Walks count. Small counts.',
    zoneAffinity: ['self'],
  ),
  Goal(
    id: 'get_unstuck',
    label: 'Get unstuck',
    subtitle: 'Stop spinning, start finishing.',
    zoneAffinity: ['purpose'],
  ),
  Goal(
    id: 'find_direction',
    label: 'Find direction',
    subtitle: 'Quieter head, clearer priorities.',
    zoneAffinity: ['purpose', 'self'],
  ),
];

class CoachingTone {
  const CoachingTone({
    required this.id,
    required this.label,
    required this.description,
    required this.example,
  });

  final String id;
  final String label;
  final String description;
  final String example;
}

const List<CoachingTone> kCoachingTones = [
  CoachingTone(
    id: 'calm',
    label: 'Calm',
    description: 'Softer, slower, leaves space.',
    example: '"A couple of quiet days is fine."',
  ),
  CoachingTone(
    id: 'practical',
    label: 'Practical',
    description: 'Straight to the useful thing.',
    example: '"Pick one: walk, water, early bed."',
  ),
  CoachingTone(
    id: 'tough_love',
    label: 'Tough love',
    description: 'Honest, a little dry. Never cruel.',
    example: "\"Don't overhaul anything. Just sleep earlier.\"",
  ),
  CoachingTone(
    id: 'reflective',
    label: 'Reflective',
    description: 'Asks a short question back.',
    example: '"What do you think tipped it?"',
  ),
];

/// 1-5 scale labels per dimension, from copy_library §3.
class ScaleLabels {
  ScaleLabels._();

  static const stress = [
    'Calm most of the time',
    'Mostly okay',
    'Up and down',
    'Tense a lot',
    'Running hot',
  ];

  static const energy = [
    'Running on empty',
    'Low',
    'Gets me through',
    'Mostly good',
    'Full tank',
  ];

  static const sleep = [
    'Broken most nights',
    'Not great',
    'Mixed',
    'Usually okay',
    'Solid',
  ];

  // Used in the daily check-in (different copy from baseline onboarding).
  static const checkInMood = ['Low', 'Flat', 'Okay', 'Good', 'Really good'];
  static const checkInStress = [
    'None',
    'Light',
    'Noticeable',
    'Heavy',
    'Overloaded',
  ];
  static const checkInEnergy = ['Empty', 'Low', 'Enough', 'Good', 'Firing'];
  static const checkInSleep = ['Broken', 'Poor', 'Mixed', 'Good', 'Solid'];
}

class Zone {
  const Zone({required this.id, required this.label, required this.subtitle});
  final String id;
  final String label;
  final String subtitle;
}

const List<Zone> kZones = [
  Zone(id: 'self', label: 'Self', subtitle: 'health, headspace, rest'),
  Zone(id: 'purpose', label: 'Purpose', subtitle: 'work, goals, what matters'),
  Zone(
    id: 'loved_ones',
    label: 'Loved Ones',
    subtitle: 'family, partner, friends',
  ),
];
