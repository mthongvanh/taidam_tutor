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

          // Goals list
          Text(
            'Lesson Content:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          SizedBox(height: Spacing.s),

          ...state.lesson.goals.map((goal) => TaiCard.margin(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Letter display
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          goal.displayText,
                          style: const TextStyle(
                            fontFamily: 'Tai Heritage Pro',
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: Spacing.m),

                    // Sound and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (goal.romanization.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pronunciation: ${goal.romanization}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: Spacing.xs),
                              ],
                            ),
                          Text(
                            goal.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          SizedBox(height: Spacing.l),

          // Begin button
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
        ],
      ),
    );
  }
}
