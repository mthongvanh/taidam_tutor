import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class CombinationsView extends StatelessWidget {
  final ReadingLessonActive state;

  const CombinationsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final combination = state.lesson.combinations[state.currentIndex];
    final progress =
        (state.currentIndex + 1) / state.lesson.combinations.length;

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
                  'Combination ${state.currentIndex + 1} of ${state.lesson.combinations.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Spacing.l),

                // Components display
                TaiCard.margin(
                  child: Column(
                    children: [
                      Text(
                        'Components:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: Spacing.m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              ...combination.componentGlyphs.map((component) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.xs),
                                child: Container(
                                  padding: EdgeInsets.all(Spacing.m),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    component,
                                    style: const TextStyle(
                                      fontFamily: 'Tai Heritage Pro',
                                      fontSize: 48,
                                    ),
                                  ),
                                ),
                              )),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: Spacing.s),
                            child: Icon(
                              Icons.add,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.m),

                // Arrow
                Icon(
                  Icons.arrow_downward,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SizedBox(height: Spacing.m),

                // Result display
                TaiCard.margin(
                  child: Column(
                    children: [
                      Text(
                        'Result:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: Spacing.m),
                      Container(
                        padding: EdgeInsets.all(Spacing.l),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          combination.result,
                          style: const TextStyle(
                            fontFamily: 'Tai Heritage Pro',
                            fontSize: 64,
                          ),
                        ),
                      ),
                      SizedBox(height: Spacing.m),
                      if (combination.romanization.isNotEmpty)
                        Text(
                          'Pronunciation: ${combination.romanization}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.m),

                // Description
                TaiCard.margin(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: Spacing.s),
                      Text(
                        combination.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.l),

                // Next button
                ElevatedButton(
                  onPressed: () =>
                      context.read<ReadingLessonCubit>().nextCombination(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: Spacing.m),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    state.currentIndex < state.lesson.combinations.length - 1
                        ? 'Next Combination'
                        : state.lesson.examples != null &&
                                state.lesson.examples!.isNotEmpty
                            ? 'See Examples'
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
