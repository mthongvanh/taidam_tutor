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

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                if (!hasCombinations && !hasExamples) ...[
                  SizedBox(height: Spacing.m),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          'This goal will take you straight to practice.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: Spacing.l),
          OutlinedButton.icon(
            onPressed: () => showGoalSelectionSheet(context, state),
            icon: const Icon(Icons.flag_outlined),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Spacing.m),
              minimumSize: const Size.fromHeight(48),
            ),
            label: const Text(
              'Choose Goal to Start From',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: Spacing.s),
          ElevatedButton(
            onPressed: () =>
                context.read<ReadingLessonCubit>().proceedToNextStage(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Spacing.m),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Begin Lesson',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: Spacing.xs),
          Text(
            hasCombinations
                ? 'You will explore how this goal combines with other glyphs next.'
                : hasExamples
                    ? 'You will review examples that include this goal next.'
                    : 'You will jump straight into practice for this goal.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          SizedBox(height: Spacing.xs),
          Text(
            'Tap the flag icon to switch goals anytime.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

Future<void> showGoalSelectionSheet(
  BuildContext context,
  ReadingLessonActive state,
) async {
  final cubit = context.read<ReadingLessonCubit>();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return FractionallySizedBox(
        heightFactor: 0.85,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Spacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jump to a Goal',
                  style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.s),
                Text(
                  'Pick any goal below to start practicing from there.',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: Spacing.m),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.lesson.goals.length,
                    separatorBuilder: (_, __) => SizedBox(height: Spacing.s),
                    itemBuilder: (_, index) {
                      final goal = state.lesson.goals[index];
                      final isCurrent = index == state.currentGoalIndex;

                      return ListTile(
                        tileColor: isCurrent
                            ? theme.colorScheme.secondaryContainer
                            : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          goal.displayText,
                          style: const TextStyle(
                            fontFamily: 'Tai Heritage Pro',
                            fontSize: 28,
                          ),
                        ),
                        subtitle: Text(
                          goal.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          isCurrent ? Icons.flag : Icons.play_arrow,
                          color: theme.colorScheme.primary,
                        ),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          cubit.selectGoal(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}
