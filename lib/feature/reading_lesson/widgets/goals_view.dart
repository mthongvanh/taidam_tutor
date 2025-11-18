import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class GoalsView extends StatelessWidget {
  final ReadingLessonActive state;

  const GoalsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final goal = state.currentGoal;
    final goalNumber = state.currentGoalIndex + 1;
    final totalGoals = state.lesson.goals.length;
    final hasCombinations = state.activeCombinations.isNotEmpty;
    final hasExamples = state.activeExamples.isNotEmpty;

    final nextActionLabel = hasCombinations
        ? 'See Combinations'
        : hasExamples
            ? 'Review Examples'
            : 'Start Practice';

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lesson description
          TaiCard.margin(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson Focus:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.s),
                Text(
                  state.lesson.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          SizedBox(height: Spacing.m),

          TaiCard.margin(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal $goalNumber of $totalGoals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          goal.displayText,
                          style: const TextStyle(
                            fontFamily: 'Tai Heritage Pro',
                            fontSize: 42,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (goal.romanization.isNotEmpty)
                            Text(
                              'Pronunciation: ${goal.romanization}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          if (goal.romanization.isNotEmpty)
                            SizedBox(height: Spacing.xs),
                          Text(
                            goal.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Spacing.m),
                Wrap(
                  spacing: Spacing.m,
                  runSpacing: Spacing.s,
                  children: [
                    _LessonChip(
                      icon: Icons.extension,
                      label:
                          '${state.activeCombinations.length} combination${state.activeCombinations.length == 1 ? '' : 's'}',
                    ),
                    _LessonChip(
                      icon: Icons.menu_book,
                      label:
                          '${state.activeExamples.length} example${state.activeExamples.length == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: Spacing.l),

          // Begin button
          ElevatedButton(
            onPressed: () =>
                context.read<ReadingLessonCubit>().proceedToNextStage(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Spacing.m),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              nextActionLabel,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LessonChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.s,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: Spacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}
