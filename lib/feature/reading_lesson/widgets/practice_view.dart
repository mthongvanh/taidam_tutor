import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/quiz_feedback_banner.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

class PracticeView extends StatelessWidget {
  final ReadingLessonActive state;

  const PracticeView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final practiceQuestions = state.practiceQuestions;
    final currentQuestion = practiceQuestions[state.currentIndex];
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
      clipBehavior: Clip.none,
      child: Text(
        currentQuestion.character,
        style: const TextStyle(
          fontFamily: 'Tai Heritage Pro',
          fontSize: 96,
        ),
        textAlign: TextAlign.center,
      ),
    );

    final isAnswerCorrect =
        state.selectedAnswerIndex == currentQuestion.correctAnswerIndex;

    final feedback = hasAnswered
        ? QuizFeedbackBanner(
            isCorrect: isAnswerCorrect,
            title: isAnswerCorrect
                ? 'Correct! Great job!'
                : 'Not quite this time.',
            message: isAnswerCorrect
                ? 'Keep the streak going.'
                : 'The correct answer is: ${currentQuestion.options[currentQuestion.correctAnswerIndex]}',
          )
        : null;

    return QuizPracticeLayout(
      currentQuestion: state.currentIndex + 1,
      totalQuestions: practiceQuestions.length,
      scoreLabel: overallScoreText,
      title: 'Which description matches this syllable or word?',
      prompt: promptCard,
      wrapPromptInCard: false,
      answerDescription: Text(
        'Select the correct answer:',
        style: Theme.of(context).textTheme.titleMedium,
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
