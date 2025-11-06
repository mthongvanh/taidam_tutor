import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_mastery.g.dart';

@JsonSerializable(explicitToJson: true)
class CharacterMastery extends Equatable {
  /// Unique identifier matching Character.characterId
  final int characterId;

  /// Total number of times this character has been practiced
  final int totalAttempts;

  /// Number of correct recognitions
  final int correctAttempts;

  /// Last time this character was practiced
  final DateTime lastPracticed;

  /// Current learning level: 0=intro, 1=drill, 2=speed
  final int currentLevel;

  const CharacterMastery({
    required this.characterId,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    required this.lastPracticed,
    this.currentLevel = 0,
  });

  /// Calculate accuracy percentage (0.0 to 1.0)
  double get accuracy =>
      totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;

  /// Character is considered mastered at 85% accuracy with at least 10 attempts
  bool get isMastered => accuracy >= 0.85 && totalAttempts >= 10;

  /// Whether this character needs review (low accuracy or not practiced recently)
  bool get needsReview {
    final daysSinceLastPractice =
        DateTime.now().difference(lastPracticed).inDays;
    return accuracy < 0.7 || daysSinceLastPractice > 7;
  }

  /// Create a copy with updated values
  CharacterMastery copyWith({
    int? characterId,
    int? totalAttempts,
    int? correctAttempts,
    DateTime? lastPracticed,
    int? currentLevel,
  }) {
    return CharacterMastery(
      characterId: characterId ?? this.characterId,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  /// Record a practice attempt
  CharacterMastery recordAttempt({required bool correct}) {
    return copyWith(
      totalAttempts: totalAttempts + 1,
      correctAttempts: correct ? correctAttempts + 1 : correctAttempts,
      lastPracticed: DateTime.now(),
    );
  }

  factory CharacterMastery.fromJson(Map<String, dynamic> json) =>
      _$CharacterMasteryFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterMasteryToJson(this);

  @override
  List<Object?> get props => [
        characterId,
        totalAttempts,
        correctAttempts,
        lastPracticed,
        currentLevel,
      ];
}
