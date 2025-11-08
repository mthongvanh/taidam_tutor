import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/flashcard/flashcard_practice_page.dart';
import 'package:taidam_tutor/feature/reading_lesson/lesson_selection_page.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(Spacing.m),
        children: [
          TaiCard.margin(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More Learning Tools',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.s),
                Text(
                  'Explore additional lessons and study resources to deepen your Tai Dam reading skills.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          SizedBox(height: Spacing.m),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FlashcardPracticePage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: TaiCard.margin(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Spacing.s),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.style,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: Spacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flashcard Practice',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Spacing.xs),
                        Text(
                          'Test yourself with multiple-choice questions and audio playback.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Spacing.m),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LessonSelectionPage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: TaiCard.margin(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Spacing.s),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: Spacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reading Lessons',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Spacing.xs),
                        Text(
                          'Review goals, study combinations, see examples, and practice reading.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
