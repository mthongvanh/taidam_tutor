import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';

class CharacterGroupSelector extends StatelessWidget {
  final Map<CharacterClass, double> classProgress;
  final Function(CharacterClass, bool) onClassSelected; // bool isPractice

  const CharacterGroupSelector({
    super.key,
    required this.classProgress,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Choose a Category',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
    ...CharacterGroupingService.getRecommendedLearningOrder()
      .map((className) => _buildClassCard(context, className)),
      ],
    );
  }

  Widget _buildClassCard(BuildContext context, CharacterClass className) {
    final theme = Theme.of(context);
    final title = CharacterGroupingService.getClassTitle(className);
    final description = CharacterGroupingService.getClassDescription(className);
    final progress = classProgress[className] ?? 0.0;
    final percentage = (progress * 100).toInt();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _getColorForClass(context, className).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForClass(className),
                    color: _getColorForClass(context, className),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getColorForClass(context, className),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getColorForClass(context, className),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onClassSelected(className, false),
                    icon: const Icon(Icons.school, size: 18),
                    label: const Text('Learn'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onClassSelected(className, true),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Practice'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  IconData _getIconForClass(CharacterClass className) {
    switch (className) {
      case CharacterClass.consonant:
        return Icons.text_fields;
      case CharacterClass.vowel:
        return Icons.circle;
      case CharacterClass.vowelCombo:
        return Icons.compare_arrows;
      case CharacterClass.special:
        return Icons.star;
      default:
        return Icons.help;
    }
  }

  Color _getColorForClass(BuildContext context, CharacterClass className) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (className) {
      case CharacterClass.consonant:
        return colorScheme.primary;
      case CharacterClass.vowel:
        return colorScheme.secondary;
      case CharacterClass.vowelCombo:
        return colorScheme.tertiary;
      case CharacterClass.special:
        return Colors.amber;
      default:
        return colorScheme.primary;
    }
  }
}
