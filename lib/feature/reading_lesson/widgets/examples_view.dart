import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class ExamplesView extends StatelessWidget {
  final ReadingLessonActive state;

  const ExamplesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final examples = state.activeExamples;

    if (examples.isEmpty) {
      return _EmptyExamples(state: state);
    }

    final progress = (state.currentIndex + 1) / examples.length;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Spacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress counter
                Text(
                  'Example ${state.currentIndex + 1} of ${examples.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Spacing.l),

                // Example word card
                TaiCard.margin(
                  child: Column(
                    children: [
                      Text(
                        'Example Word:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: Spacing.l),
                      Container(
                        padding: EdgeInsets.all(Spacing.l),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          examples[state.currentIndex].displayWord,
                          style: const TextStyle(
                            fontFamily: 'Tai Heritage Pro',
                            fontSize: 72,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: Spacing.l),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.m,
                          vertical: Spacing.s,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          examples[state.currentIndex].displayRomanization,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.m),

                // Info card
                TaiCard.margin(
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      SizedBox(width: Spacing.s),
                      Expanded(
                        child: Text(
                          'Study this example to see how the combinations work in real words.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.l),

                // Next button
                ElevatedButton(
                  onPressed: () =>
                      context.read<ReadingLessonCubit>().nextExample(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: Spacing.m),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    state.currentIndex < examples.length - 1
                        ? 'Next Example'
                        : 'Start Practice',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyExamples extends StatelessWidget {
  final ReadingLessonActive state;

  const _EmptyExamples({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Spacing.l),
      child: TaiCard.margin(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: Spacing.m),
            Text(
              'No examples for ${state.currentGoal.displayText} in this lesson.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Spacing.s),
            Text(
              'Jump straight into practice to reinforce this goal.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Spacing.l),
            ElevatedButton(
              onPressed: () =>
                  context.read<ReadingLessonCubit>().proceedToNextStage(),
              child: const Text('Start Practice'),
            ),
          ],
        ),
      ),
    );
  }
}
