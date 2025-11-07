import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

/// Achievement types that can be unlocked
enum AchievementType {
  /// First practice session completed
  firstPractice,

  /// Completed a session with 100% accuracy
  perfectScore,

  /// Completed 10 practice sessions
  dedicated,

  /// Completed 50 practice sessions
  committed,

  /// Mastered 10 characters
  learner,

  /// Mastered 25 characters
  scholar,

  /// Mastered all consonants
  consonantMaster,

  /// Mastered all vowels
  vowelMaster,

  /// 7-day practice streak
  weekWarrior,

  /// 30-day practice streak
  monthlyMaster,

  /// Answered 100 questions correctly
  centurion,

  /// Answered 500 questions correctly
  expert,
}

@JsonSerializable(explicitToJson: true)
class Achievement extends Equatable {
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock() {
    return Achievement(
      type: type,
      title: title,
      description: description,
      icon: icon,
      unlockedAt: DateTime.now(),
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  @override
  List<Object?> get props => [type, title, description, icon, unlockedAt];

  static List<Achievement> getAllAchievements() {
    return [
      const Achievement(
        type: AchievementType.firstPractice,
        title: 'First Steps',
        description: 'Complete your first practice session',
        icon: '🎯',
      ),
      const Achievement(
        type: AchievementType.perfectScore,
        title: 'Perfect!',
        description: 'Get 100% accuracy in a session',
        icon: '💯',
      ),
      const Achievement(
        type: AchievementType.dedicated,
        title: 'Dedicated',
        description: 'Complete 10 practice sessions',
        icon: '📚',
      ),
      const Achievement(
        type: AchievementType.committed,
        title: 'Committed',
        description: 'Complete 50 practice sessions',
        icon: '🏆',
      ),
      const Achievement(
        type: AchievementType.learner,
        title: 'Learner',
        description: 'Master 10 characters',
        icon: '📖',
      ),
      const Achievement(
        type: AchievementType.scholar,
        title: 'Scholar',
        description: 'Master 25 characters',
        icon: '🎓',
      ),
      const Achievement(
        type: AchievementType.consonantMaster,
        title: 'Consonant Master',
        description: 'Master all consonants',
        icon: '🔤',
      ),
      const Achievement(
        type: AchievementType.vowelMaster,
        title: 'Vowel Master',
        description: 'Master all vowels',
        icon: '🔠',
      ),
      const Achievement(
        type: AchievementType.weekWarrior,
        title: 'Week Warrior',
        description: 'Practice 7 days in a row',
        icon: '🔥',
      ),
      const Achievement(
        type: AchievementType.monthlyMaster,
        title: 'Monthly Master',
        description: 'Practice 30 days in a row',
        icon: '⭐',
      ),
      const Achievement(
        type: AchievementType.centurion,
        title: 'Centurion',
        description: 'Answer 100 questions correctly',
        icon: '💪',
      ),
      const Achievement(
        type: AchievementType.expert,
        title: 'Expert',
        description: 'Answer 500 questions correctly',
        icon: '👑',
      ),
    ];
  }

  /// Check which achievements should be unlocked based on current stats
  static List<AchievementType> checkAchievements({
    required int totalSessions,
    required int masteredCharacters,
    required int totalCorrectAnswers,
    required int practiceStreak,
    required bool hadPerfectSession,
    required int masteredConsonants,
    required int masteredVowels,
    required int totalConsonants,
    required int totalVowels,
  }) {
    final unlocked = <AchievementType>[];

    // First practice
    if (totalSessions >= 1) {
      unlocked.add(AchievementType.firstPractice);
    }

    // Perfect score
    if (hadPerfectSession) {
      unlocked.add(AchievementType.perfectScore);
    }

    // Session milestones
    if (totalSessions >= 10) {
      unlocked.add(AchievementType.dedicated);
    }
    if (totalSessions >= 50) {
      unlocked.add(AchievementType.committed);
    }

    // Mastery milestones
    if (masteredCharacters >= 10) {
      unlocked.add(AchievementType.learner);
    }
    if (masteredCharacters >= 25) {
      unlocked.add(AchievementType.scholar);
    }

    // Class mastery
    if (masteredConsonants >= totalConsonants && totalConsonants > 0) {
      unlocked.add(AchievementType.consonantMaster);
    }
    if (masteredVowels >= totalVowels && totalVowels > 0) {
      unlocked.add(AchievementType.vowelMaster);
    }

    // Streaks
    if (practiceStreak >= 7) {
      unlocked.add(AchievementType.weekWarrior);
    }
    if (practiceStreak >= 30) {
      unlocked.add(AchievementType.monthlyMaster);
    }

    // Correct answers
    if (totalCorrectAnswers >= 100) {
      unlocked.add(AchievementType.centurion);
    }
    if (totalCorrectAnswers >= 500) {
      unlocked.add(AchievementType.expert);
    }

    return unlocked;
  }
}
