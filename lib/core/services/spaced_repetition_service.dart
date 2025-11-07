import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';

/// Service for implementing spaced repetition and review scheduling
class SpacedRepetitionService {
  /// Get characters that need review based on performance and time
  static List<Character> getCharactersNeedingReview(
    List<Character> allCharacters,
    Map<int, CharacterMastery> masteryData,
  ) {
    final needsReview = <Character>[];

    for (final character in allCharacters) {
      final mastery = masteryData[character.characterId];

      if (mastery == null) {
        // Never practiced - needs review
        needsReview.add(character);
      } else if (mastery.needsReview) {
        // Based on accuracy or time since last practice
        needsReview.add(character);
      }
    }

    return needsReview;
  }

  /// Get characters sorted by priority (worst performing first)
  static List<Character> getPrioritizedCharacters(
    List<Character> characters,
    Map<int, CharacterMastery> masteryData,
  ) {
    final characterList = List<Character>.from(characters);

    characterList.sort((a, b) {
      final masteryA = masteryData[a.characterId];
      final masteryB = masteryData[b.characterId];

      // Unpracticed characters come first
      if (masteryA == null && masteryB != null) return -1;
      if (masteryA != null && masteryB == null) return 1;
      if (masteryA == null && masteryB == null) return 0;

      // Sort by accuracy (lowest first)
      final accuracyDiff = masteryA!.accuracy.compareTo(masteryB!.accuracy);
      if (accuracyDiff != 0) return accuracyDiff;

      // If same accuracy, sort by least recently practiced
      return masteryA.lastPracticed.compareTo(masteryB.lastPracticed);
    });

    return characterList;
  }

  /// Get review interval in days based on accuracy
  static int getReviewIntervalDays(double accuracy) {
    if (accuracy >= 0.9) return 7; // Weekly review
    if (accuracy >= 0.8) return 3; // Review every 3 days
    if (accuracy >= 0.7) return 1; // Daily review
    return 0; // Immediate review needed
  }

  /// Determine if character should be reviewed based on spaced repetition
  static bool shouldReview(CharacterMastery mastery) {
    final daysSinceLastPractice =
        DateTime.now().difference(mastery.lastPracticed).inDays;
    final requiredInterval = getReviewIntervalDays(mastery.accuracy);

    return daysSinceLastPractice >= requiredInterval || mastery.accuracy < 0.7;
  }

  /// Get recommended practice session size based on total characters
  static int getRecommendedSessionSize(int totalCharacters) {
    if (totalCharacters <= 5) return totalCharacters;
    if (totalCharacters <= 10) return 5;
    if (totalCharacters <= 20) return 8;
    return 10;
  }

  /// Calculate retention rate (how well mastered characters are retained)
  static double calculateRetentionRate(Map<int, CharacterMastery> masteryData) {
    if (masteryData.isEmpty) return 0.0;

    final masteredCharacters = masteryData.values.where((m) => m.isMastered);
    if (masteredCharacters.isEmpty) return 0.0;

    // Characters mastered but needing review = retention issue
    final retainedCharacters = masteredCharacters.where((m) => !m.needsReview);

    return retainedCharacters.length / masteredCharacters.length;
  }

  /// Get learning velocity (characters mastered per day)
  static double calculateLearningVelocity(
    Map<int, CharacterMastery> masteryData,
    int daysSinceStart,
  ) {
    if (daysSinceStart == 0) return 0.0;

    final masteredCount = masteryData.values.where((m) => m.isMastered).length;
    return masteredCount / daysSinceStart;
  }

  /// Get streak of consecutive days with practice
  static int calculatePracticeStreak(List<DateTime> practiceDates) {
    if (practiceDates.isEmpty) return 0;

    final sortedDates = practiceDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    int streak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (lastDate == null) {
        // First date
        final today = DateTime.now();
        final todayNormalized = DateTime(today.year, today.month, today.day);

        if (normalizedDate == todayNormalized ||
            normalizedDate ==
                todayNormalized.subtract(const Duration(days: 1))) {
          streak = 1;
          lastDate = normalizedDate;
        } else {
          break; // Streak is broken
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (normalizedDate == expectedDate) {
          streak++;
          lastDate = normalizedDate;
        } else {
          break; // Gap in streak
        }
      }
    }

    return streak;
  }
}
