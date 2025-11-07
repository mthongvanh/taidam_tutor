import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/progress_info_page.dart';

class ProgressDashboard extends StatelessWidget {
  final Map<String, double> classProgress;
  final double overallProgress;
  final Map<String, dynamic> stats;

  const ProgressDashboard({
    super.key,
    required this.classProgress,
    required this.overallProgress,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Progress',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProgressInfoPage(),
                      ),
                    );
                  },
                  tooltip: 'Learn about progress tracking',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Overall progress
            _buildOverallProgress(context),
            const SizedBox(height: 24),

            // Stats grid
            _buildStatsGrid(context),
            const SizedBox(height: 24),

            // Character class progress
            Text(
              'Progress by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...CharacterGroupingService.getRecommendedLearningOrder()
                .map((className) => _buildClassProgress(
                      context,
                      className,
                      classProgress[className] ?? 0.0,
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (overallProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Mastery',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: overallProgress,
            minHeight: 12,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Characters',
            '${stats['masteredCharacters'] ?? 0}/${stats['totalCharacters'] ?? 0}',
            Icons.font_download,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Accuracy',
            '${((stats['overallAccuracy'] ?? 0.0) * 100).toInt()}%',
            Icons.check_circle,
            theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Practice',
            '${stats['totalAttempts'] ?? 0}',
            Icons.repeat,
            theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassProgress(
    BuildContext context,
    String className,
    double progress,
  ) {
    final theme = Theme.of(context);
    final title = CharacterGroupingService.getClassTitle(className);
    final percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForClass(context, className),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForClass(BuildContext context, String className) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (className) {
      case 'consonant':
        return colorScheme.primary;
      case 'vowel':
        return colorScheme.secondary;
      case 'vowel-combo':
        return colorScheme.tertiary;
      case 'special':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }
}
