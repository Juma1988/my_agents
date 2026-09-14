import 'challenge_segment.dart';

enum HeartState { off, liked, loved, disabled }

class ChallengeCategory {
  final String id;
  final String name;
  final String icon; // emoji character
  final List<ChallengeSegment> soft;
  final List<ChallengeSegment> kink;
  final List<ChallengeSegment> entertainment;
  HeartState heartState;
  bool softEnabled;
  bool kinkEnabled;
  bool entertainmentEnabled;

  ChallengeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.soft,
    required this.kink,
    required this.entertainment,
    this.heartState = HeartState.off,
    this.softEnabled = true,
    this.kinkEnabled = true,
    this.entertainmentEnabled = true,
  });

  /// Number of wheel slices this category gets (0 = disabled)
  int get value {
    switch (heartState) {
      case HeartState.off:
        return 1;
      case HeartState.liked:
        return 2;
      case HeartState.loved:
        return 3;
      case HeartState.disabled:
        return 0;
    }
  }

  bool get isEnabled => heartState != HeartState.disabled;

  /// Human-readable heart display character
  String get heartDisplay {
    switch (heartState) {
      case HeartState.off:
        return '🤍';
      case HeartState.liked:
        return '❤️';
      case HeartState.loved:
        return '🔥';
      case HeartState.disabled:
        return '💔';
    }
  }

  /// Chance percentage as a fraction of total slices
  double chancePercent(int totalSlices) {
    if (totalSlices == 0) return 0;
    return (value / totalSlices) * 100;
  }

  /// Get the enabled tier lists
  List<ChallengeSegment> get enabledTiers {
    final List<ChallengeSegment> tiers = [];
    if (softEnabled) tiers.addAll(soft);
    if (kinkEnabled) tiers.addAll(kink);
    if (entertainmentEnabled) tiers.addAll(entertainment);
    return tiers;
  }

  /// Get tasks from a specific tier (only if that tier is enabled)
  List<ChallengeSegment> tasksForTier(String tier) {
    switch (tier) {
      case 'soft':
        return softEnabled ? soft : [];
      case 'kink':
        return kinkEnabled ? kink : [];
      case 'entertainment':
        return entertainmentEnabled ? entertainment : [];
      default:
        return [];
    }
  }

  /// Cycle the heart state: off → liked → loved → disabled → off
  void cycleHeart() {
    switch (heartState) {
      case HeartState.off:
        heartState = HeartState.liked;
        break;
      case HeartState.liked:
        heartState = HeartState.loved;
        break;
      case HeartState.loved:
        heartState = HeartState.disabled;
        break;
      case HeartState.disabled:
        heartState = HeartState.off;
        break;
    }
  }

  factory ChallengeCategory.fromJson(Map<String, dynamic> json) {
    return ChallengeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      soft: (json['soft'] as List)
          .map((e) => ChallengeSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      kink: (json['kink'] as List)
          .map((e) => ChallengeSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      entertainment: (json['entertainment'] as List)
          .map((e) => ChallengeSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
