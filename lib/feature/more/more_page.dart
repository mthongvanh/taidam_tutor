import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/flashcard/flashcard_practice_page.dart';
import 'package:taidam_tutor/feature/letter_search/letter_search.dart';
import 'package:taidam_tutor/feature/quiz/quiz_page.dart';
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
                  builder: (context) => LetterSearchGame(),
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
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: Spacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Letter Finder Game',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Spacing.xs),
                        Text(
                          'Search for matching characters as quickly as you can.',
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
                  builder: (context) => QuizPage(),
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
                      Icons.quiz,
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
                          'Quiz Yourself',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: Spacing.xs),
                        Text(
                          'Check what you remember with mixed multiple-choice questions.',
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
