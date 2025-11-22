import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/reading_lessons.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/reading_lesson_page.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class LessonSelectionPage extends StatelessWidget {
  const LessonSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = ReadingLessons.lessons
        .map((lesson) => lesson['lesson'] as Map<String, dynamic>)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Lessons'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(Spacing.m),
        itemCount: lessons.length + 1,
        separatorBuilder: (context, index) => SizedBox(height: Spacing.m),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TaiCard.margin(
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
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
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
            );
          }

          final lessonData = lessons[index - 1];
          final lessonNumber = lessonData['number'] as int? ?? index;
          final shortDescription = lessonData['shortDescription'] as String? ??
              lessonData['description'] as String? ?? '';
          final goals = lessonData['goals'] as List? ?? const [];
          final combinations = lessonData['combinations'] as List? ?? const [];
          final examples = lessonData['examples'] as List?;

          return _LessonCard(
            lessonNumber: lessonNumber,
            title: lessonData['title'] as String? ?? 'Lesson $lessonNumber',
            shortDescription: shortDescription,
            goalCount: goals.length,
            combinationCount: combinations.length,
            exampleCount: examples?.length ?? 0,
          );
        },
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
