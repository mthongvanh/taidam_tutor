import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/achievement.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/learning_session.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/core/services/spaced_repetition_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/achievement_badge.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/analytics_card.dart';

class AnalyticsPage extends StatelessWidget {
  final List<LearningSession> sessions;
  final Map<int, CharacterMastery> masteryData;
  final Map<CharacterClass, List<Character>> characterGroups;
  final Map<String, dynamic> stats;
  final double overallProgress;

  const AnalyticsPage({
    super.key,
    required this.sessions,
    required this.masteryData,
    required this.characterGroups,
    required this.stats,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Analytics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Overall Performance
            _buildPerformanceCard(context, theme),

            // Learning Progress
            _buildProgressCard(context, theme),

            // Achievements
            _buildAchievementsSection(context, theme),

            // Review Recommendations
            _buildReviewRecommendations(context, theme),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    BuildContext context,
    ThemeData theme,
  ) {
    final completedSessions = sessions.where((s) => !s.isActive).toList();

    final totalQuestions = completedSessions.fold<int>(
      0,
      (sum, s) => sum + s.questionsAnswered,
    );

    final practiceDates = completedSessions.map((s) => s.startTime).toList();

    final streak =
        SpacedRepetitionService.calculatePracticeStreak(practiceDates);

    return AnalyticsCard(
      title: 'Performance',
      stats: [
        AnalyticsStat(
          label: 'Overall Accuracy',
          value: '${((stats['overallAccuracy'] ?? 0.0) * 100).toInt()}%',
          icon: Icons.percent,
          color: theme.colorScheme.primary,
        ),
        AnalyticsStat(
          label: 'Total Sessions',
          value: '${completedSessions.length}',
          subtitle: '$totalQuestions questions answered',
          icon: Icons.assignment,
          color: theme.colorScheme.secondary,
        ),
        AnalyticsStat(
          label: 'Practice Streak',
          value: '$streak day${streak == 1 ? '' : 's'}',
          subtitle: streak > 0 ? 'Keep it up!' : 'Start practicing today!',
          icon: Icons.local_fire_department,
          color: streak >= 7 ? Colors.orange : theme.colorScheme.tertiary,
        ),
        AnalyticsStat(
          label: 'Retention Rate',
          value:
              '${(SpacedRepetitionService.calculateRetentionRate(masteryData) * 100).toInt()}%',
          subtitle: 'Mastered characters retained',
          icon: Icons.psychology,
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    ThemeData theme,
  ) {
    final masteredCount = stats['masteredCharacters'] ?? 0;
    final totalCount = stats['totalCharacters'] ?? 1;

    final charactersNeedingReview =
        SpacedRepetitionService.getCharactersNeedingReview(
      characterGroups.values.expand((list) => list).toList(),
      masteryData,
    ).length;

    return AnalyticsCard(
      title: 'Learning Progress',
      stats: [
        AnalyticsStat(
          label: 'Characters Mastered',
          value: '$masteredCount / $totalCount',
          subtitle: '${(overallProgress * 100).toInt()}% complete',
          icon: Icons.school,
          color: theme.colorScheme.primary,
        ),
        AnalyticsStat(
          label: 'Needs Review',
          value: '$charactersNeedingReview',
          subtitle: charactersNeedingReview > 0
              ? 'Practice these soon'
              : 'All caught up!',
          icon: Icons.refresh,
          color: charactersNeedingReview > 0 ? Colors.orange : Colors.green,
        ),
        ...CharacterGroupingService.getRecommendedLearningOrder().map(
          (className) {
            final characters = characterGroups[className] ?? [];
            final mastered = characters
                .where((c) => masteryData[c.characterId]?.isMastered ?? false)
                .length;
            final progress =
                characters.isNotEmpty ? mastered / characters.length : 0.0;

            return AnalyticsStat(
              label: CharacterGroupingService.getClassTitle(className),
              value: '$mastered / ${characters.length}',
              subtitle: '${(progress * 100).toInt()}% mastered',
              icon: Icons.category,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    ThemeData theme,
  ) {
    final completedSessions = sessions.where((s) => !s.isActive).toList();

    final practiceDates = completedSessions.map((s) => s.startTime).toList();
    final streak =
        SpacedRepetitionService.calculatePracticeStreak(practiceDates);

    final hadPerfectSession = completedSessions.any((s) => s.accuracy >= 1.0);

    // Get mastered counts by class
  final consonants = characterGroups[CharacterClass.consonant] ?? [];
  final vowels = characterGroups[CharacterClass.vowel] ?? [];
    final masteredConsonants = consonants
        .where((c) => masteryData[c.characterId]?.isMastered ?? false)
        .length;
    final masteredVowels = vowels
        .where((c) => masteryData[c.characterId]?.isMastered ?? false)
        .length;

    final unlockedTypes = Achievement.checkAchievements(
      totalSessions: completedSessions.length,
      masteredCharacters: stats['masteredCharacters'] ?? 0,
      totalCorrectAnswers: stats['totalCorrect'] ?? 0,
      practiceStreak: streak,
      hadPerfectSession: hadPerfectSession,
      masteredConsonants: masteredConsonants,
      masteredVowels: masteredVowels,
      totalConsonants: consonants.length,
      totalVowels: vowels.length,
    );

    final allAchievements = Achievement.getAllAchievements();
    final achievements = allAchievements.map((achievement) {
      if (unlockedTypes.contains(achievement.type)) {
        return achievement.unlock();
      }
      return achievement;
    }).toList();

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlockedCount / ${achievements.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: AchievementBadge(
                  achievement: achievement,
                  onTap: () => _showAchievementDialog(context, achievement),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRecommendations(
    BuildContext context,
    ThemeData theme,
  ) {
    final allCharacters =
        characterGroups.values.expand((list) => list).toList();

    final needsReview = SpacedRepetitionService.getCharactersNeedingReview(
      allCharacters,
      masteryData,
    );

    if (needsReview.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Caught Up!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No characters need review right now. Keep up the great work!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final prioritized = SpacedRepetitionService.getPrioritizedCharacters(
      needsReview,
      masteryData,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended Review',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${needsReview.length} character${needsReview.length == 1 ? '' : 's'} need review',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Top Priority:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prioritized.take(10).map((character) {
                final mastery = masteryData[character.characterId];
                return Chip(
                  label: Text(
                    character.romanization ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                  avatar: Text(
                    character.character,
                    style: const TextStyle(
                      fontFamily: 'Tai Heritage Pro',
                      fontSize: 16,
                    ),
                  ),
                  backgroundColor: mastery == null
                      ? theme.colorScheme.errorContainer
                      : mastery.accuracy < 0.5
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDialog(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(achievement.title),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Locked',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
