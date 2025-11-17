import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/achievement.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';

class DrillCompletionCard extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final CharacterClass characterClass;
  final List<Achievement> newlyUnlockedAchievements;
  final VoidCallback onContinue;
  final VoidCallback onRestart;

  const DrillCompletionCard({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.characterClass,
    this.newlyUnlockedAchievements = const [],
    required this.onContinue,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (accuracy * 100).toInt();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getColorForAccuracy(accuracy, theme).withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForAccuracy(accuracy),
                size: 60,
                color: _getColorForAccuracy(accuracy, theme),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              _getTitleForAccuracy(accuracy),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              CharacterGroupingService.getClassTitle(characterClass),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Score display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$percentage',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctAnswers / $totalQuestions correct',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Message
            Text(
              _getMessageForAccuracy(accuracy),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            // Newly unlocked achievements
            if (newlyUnlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withAlpha(51),
                      Colors.orange.withAlpha(26),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.celebration,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Achievement${newlyUnlockedAchievements.length > 1 ? 's' : ''} Unlocked!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...newlyUnlockedAchievements.map((achievement) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      achievement.description,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Practice Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContinue,
                    icon: const Icon(Icons.check),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAccuracy(double accuracy) {
    if (accuracy >= 0.9) return Icons.emoji_events;
    if (accuracy >= 0.7) return Icons.thumb_up;
    return Icons.trending_up;
  }

  Color _getColorForAccuracy(double accuracy, ThemeData theme) {
    if (accuracy >= 0.9) return Colors.amber;
    if (accuracy >= 0.7) return theme.colorScheme.primary;
    return theme.colorScheme.secondary;
  }

  String _getTitleForAccuracy(double accuracy) {
    if (accuracy >= 0.9) return 'Excellent Work!';
    if (accuracy >= 0.7) return 'Great Job!';
    if (accuracy >= 0.5) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  String _getMessageForAccuracy(double accuracy) {
    if (accuracy >= 0.9) {
      return 'Outstanding! You\'ve mastered these characters.';
    }
    if (accuracy >= 0.7) {
      return 'You\'re making great progress. Keep it up!';
    }
    if (accuracy >= 0.5) {
      return 'You\'re on the right track. Practice makes perfect!';
    }
    return 'Don\'t give up! Review and try again.';
  }
}
