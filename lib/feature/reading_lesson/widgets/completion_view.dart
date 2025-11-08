import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class CompletionView extends StatelessWidget {
  final ReadingLessonCompleted state;

  const CompletionView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final percentage = state.percentage;

    // Determine emoji and message based on percentage
    String emoji;
    String title;
    String message;

    if (percentage >= 90) {
      emoji = '🏆';
      title = 'Outstanding!';
      message = 'You\'ve mastered this lesson!';
    } else if (percentage >= 70) {
      emoji = '🎉';
      title = 'Great Job!';
      message = 'You\'re making excellent progress!';
    } else if (percentage >= 50) {
      emoji = '👍';
      title = 'Well Done!';
      message = 'Keep practicing to improve!';
    } else {
      emoji = '💪';
      title = 'Keep Going!';
      message = 'Practice makes perfect!';
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Spacing.xl),

          // Emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 96),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Spacing.m),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Spacing.s),

          // Message
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Spacing.xl),

          // Score card
          TaiCard.margin(
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${state.score}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      ' / ${state.totalQuestions}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                  ],
                ),
                SizedBox(height: Spacing.s),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: Spacing.m),

          // Lesson title
          TaiCard.margin(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson Completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: Spacing.s),
                Text(
                  state.lesson.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          SizedBox(height: Spacing.l),

          // Restart button
          ElevatedButton(
            onPressed: () => context.read<ReadingLessonCubit>().restartLesson(),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Spacing.m),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Restart Lesson',
              style: TextStyle(fontSize: 18),
            ),
          ),

          SizedBox(height: Spacing.s),

          // Return button
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: Spacing.m),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Return to Lessons',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
