/// Coaching-tone preference. Mirrors the `coaching_tone` Postgres enum
/// declared in `supabase/migrations/001_init.sql`.
enum CoachingTone {
  calm,
  practical,
  toughLove,
  reflective;

  /// The exact string Postgres expects when writing this value.
  /// Note `tough_love` is the SQL form (the Dart enum drops the underscore
  /// for camelCase).
  String get wireName {
    switch (this) {
      case CoachingTone.calm:
        return 'calm';
      case CoachingTone.practical:
        return 'practical';
      case CoachingTone.toughLove:
        return 'tough_love';
      case CoachingTone.reflective:
        return 'reflective';
    }
  }

  static CoachingTone? fromWire(String? wire) {
    switch (wire) {
      case 'calm':
        return CoachingTone.calm;
      case 'practical':
        return CoachingTone.practical;
      case 'tough_love':
        return CoachingTone.toughLove;
      case 'reflective':
        return CoachingTone.reflective;
    }
    return null;
  }
}

/// The three energy zones. Mirrors the `zone` Postgres enum.
enum Zone {
  self,
  purpose,
  lovedOnes;

  String get wireName {
    switch (this) {
      case Zone.self:
        return 'self';
      case Zone.purpose:
        return 'purpose';
      case Zone.lovedOnes:
        return 'loved_ones';
    }
  }

  static Zone? fromWire(String? wire) {
    switch (wire) {
      case 'self':
        return Zone.self;
      case 'purpose':
        return Zone.purpose;
      case 'loved_ones':
        return Zone.lovedOnes;
    }
    return null;
  }
}

/// A user's profile row. 1:1 with `auth.users` via the auth trigger.
class Profile {
  const Profile({
    required this.userId,
    required this.coachingTone,
    required this.onboardingComplete,
    this.displayName,
    this.goal,
    this.preferredZone,
  });

  final String userId;
  final String? displayName;
  final String? goal;
  final CoachingTone coachingTone;
  final Zone? preferredZone;
  final bool onboardingComplete;

  factory Profile.fromRow(Map<String, dynamic> row) {
    return Profile(
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String?,
      goal: row['goal'] as String?,
      coachingTone:
          CoachingTone.fromWire(row['coaching_tone'] as String?) ?? CoachingTone.calm,
      preferredZone: Zone.fromWire(row['preferred_zone'] as String?),
      onboardingComplete: (row['onboarding_complete'] as bool?) ?? false,
    );
  }
}
