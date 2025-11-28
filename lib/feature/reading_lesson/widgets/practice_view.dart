import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';

class PracticeView extends StatelessWidget {
  final ReadingLessonActive state;

  const PracticeView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final practiceQuestions = state.practiceQuestions;
    final currentQuestion = practiceQuestions[state.currentIndex];
    final progress = (state.currentIndex + 1) / practiceQuestions.length;
    final hasAnswered = state.selectedAnswerIndex != null;
    final totalQuestions = state.totalPracticeQuestions;
    final isLastQuestion = state.currentIndex >= practiceQuestions.length - 1;
    final hasMoreGoals = state.currentGoalIndex < state.lesson.goals.length - 1;
    final overallScoreText = totalQuestions > 0
        ? 'Lesson Score: ${state.score} / $totalQuestions'
        : 'Lesson Score: ${state.score}';

    String ctaLabel() {
      if (!hasAnswered) return 'Next Question';
      if (!isLastQuestion) return 'Next Question';
      return hasMoreGoals ? 'Continue Lesson' : 'See Results';
    }

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
                  'Question ${state.currentIndex + 1} of ${practiceQuestions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Spacing.m),

                // Score display
                Container(
                  padding: EdgeInsets.all(Spacing.s),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        overallScoreText,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Spacing.xs),
                      Text(
                        'Current goal: ${state.currentGoal.displayText}${state.currentGoal.romanization.isNotEmpty ? ' (${state.currentGoal.romanization})' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Spacing.l),

                // Question prompt
                Text(
                  'Which description matches this syllable?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Spacing.m),

                // Character display
                TaiCard.margin(
                  child: Container(
                    padding: EdgeInsets.all(Spacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentQuestion.character,
                      style: const TextStyle(
                        fontFamily: 'Tai Heritage Pro',
                        fontSize: 96,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: Spacing.l),

                // Answer options
                ...List.generate(
                  currentQuestion.options.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: Spacing.s),
                    child: AnswerOptionButton(
                      label: String.fromCharCode(65 + index), // A, B, C, D
                      option: currentQuestion.options[index],
                      isSelected: state.selectedAnswerIndex == index,
                      isCorrect: index == currentQuestion.correctAnswerIndex,
                      hasAnswered: hasAnswered,
                      onTap: hasAnswered
                          ? null
                          : () => context
                              .read<ReadingLessonCubit>()
                              .selectAnswer(index),
                    ),
                  ),
                ),

                if (hasAnswered) ...[
                  SizedBox(height: Spacing.l),

                  // Feedback
                  Container(
                    padding: EdgeInsets.all(Spacing.m),
                    decoration: BoxDecoration(
                      color: state.selectedAnswerIndex ==
                              currentQuestion.correctAnswerIndex
                          ? Colors.green.withAlpha(26)
                          : Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.selectedAnswerIndex ==
                                currentQuestion.correctAnswerIndex
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.selectedAnswerIndex ==
                                  currentQuestion.correctAnswerIndex
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: state.selectedAnswerIndex ==
                                  currentQuestion.correctAnswerIndex
                              ? Colors.green
                              : Colors.red,
                          size: 32,
                        ),
                        SizedBox(width: Spacing.s),
                        Expanded(
                          child: Text(
                            state.selectedAnswerIndex ==
                                    currentQuestion.correctAnswerIndex
                                ? 'Correct! Great job!'
                                : 'Not quite. The correct answer is: ${currentQuestion.options[currentQuestion.correctAnswerIndex]}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Spacing.l),

                  // Next button
                  ElevatedButton(
                    onPressed: () => context
                        .read<ReadingLessonCubit>()
                        .nextPracticeQuestion(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: Spacing.m),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      ctaLabel(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
