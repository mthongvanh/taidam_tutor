import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

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

    final promptCard = TaiCard.margin(
      child: Text(
        currentQuestion.character,
        style: const TextStyle(
          fontFamily: 'Tai Heritage Pro',
          fontSize: 96,
        ),
        textAlign: TextAlign.center,
      ),
    );

    final feedback = hasAnswered
        ? Container(
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          )
        : null;

    return QuizPracticeLayout(
      currentQuestion: state.currentIndex + 1,
      totalQuestions: practiceQuestions.length,
      scoreLabel: overallScoreText,
      title: 'Which description matches this syllable?',
      prompt: promptCard,
      wrapPromptInCard: false,
      answerDescription: Text(
        'Select the description that matches this syllable.',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      answerOptions: List.generate(
        currentQuestion.options.length,
        (index) => AnswerOptionButton(
          label: String.fromCharCode(65 + index),
          option: currentQuestion.options[index],
          isSelected: state.selectedAnswerIndex == index,
          isCorrect: index == currentQuestion.correctAnswerIndex,
          hasAnswered: hasAnswered,
          onTap: hasAnswered
              ? null
              : () => context.read<ReadingLessonCubit>().selectAnswer(index),
        ),
      ),
      feedback: feedback,
      bottomButton: hasAnswered
          ? ElevatedButton(
              onPressed: () =>
                  context.read<ReadingLessonCubit>().nextPracticeQuestion(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: Spacing.m),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                ctaLabel(),
                style: const TextStyle(fontSize: 18),
              ),
            )
          : null,
    );
  }
}
