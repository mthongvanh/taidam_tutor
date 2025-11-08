import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/reading_lessons.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/reading_lesson_page.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class LessonSelectionPage extends StatelessWidget {
  const LessonSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lesson1Data =
        ReadingLessons.lesson1['lesson'] as Map<String, dynamic>;
    final lesson2Data =
        ReadingLessons.lesson2['lesson'] as Map<String, dynamic>;
    final lesson1ShortDescription =
        lesson1Data['shortDescription'] as String? ??
            lesson1Data['description'] as String;
    final lesson2ShortDescription =
        lesson2Data['shortDescription'] as String? ??
            lesson2Data['description'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Lessons'),
      ),
      body: ListView(
        padding: EdgeInsets.all(Spacing.m),
        children: [
          // Page header
          TaiCard.margin(
            child: Column(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: Spacing.m),
                Text(
                  'Choose a Lesson',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Spacing.s),
                Text(
                  'Select a reading lesson to study character combinations and practice reading.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: Spacing.m),

          // Lesson 1
          _LessonCard(
            lessonNumber: 1,
            title: lesson1Data['title'] as String,
            shortDescription: lesson1ShortDescription,
            goalCount: (lesson1Data['goals'] as List).length,
            combinationCount: (lesson1Data['combinations'] as List).length,
            exampleCount: lesson1Data['examples'] != null
                ? (lesson1Data['examples'] as List).length
                : 0,
          ),

          SizedBox(height: Spacing.m),

          // Lesson 2
          _LessonCard(
            lessonNumber: 2,
            title: lesson2Data['title'] as String,
            shortDescription: lesson2ShortDescription,
            goalCount: (lesson2Data['goals'] as List).length,
            combinationCount: (lesson2Data['combinations'] as List).length,
            exampleCount: lesson2Data['examples'] != null
                ? (lesson2Data['examples'] as List).length
                : 0,
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int lessonNumber;
  final String title;
  final String shortDescription;
  final int goalCount;
  final int combinationCount;
  final int exampleCount;

  const _LessonCard({
    required this.lessonNumber,
    required this.title,
    required this.shortDescription,
    required this.goalCount,
    required this.combinationCount,
    required this.exampleCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReadingLessonPage(lessonNumber: lessonNumber),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: TaiCard.margin(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$lessonNumber',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                  ),
                ),
                SizedBox(width: Spacing.m),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: Spacing.m),
            Text(
              shortDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: Spacing.m),
            Wrap(
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: [
                _InfoChip(
                  icon: Icons.flag,
                  label: '$goalCount Goals',
                ),
                _InfoChip(
                  icon: Icons.abc,
                  label: '$combinationCount Combinations',
                ),
                if (exampleCount > 0)
                  _InfoChip(
                    icon: Icons.format_list_bulleted,
                    label: '$exampleCount Examples',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.s,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: Spacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}
