import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class PracticeView extends StatelessWidget {
  final ReadingLessonActive state;

  const PracticeView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final practiceQuestions = state.practiceQuestions!;
    final currentQuestion = practiceQuestions[state.currentIndex];
    final progress = (state.currentIndex + 1) / practiceQuestions.length;
    final hasAnswered = state.selectedAnswerIndex != null;

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
                  child: Text(
                    'Score: ${state.score} / ${practiceQuestions.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: Spacing.l),

                // Question prompt
                Text(
                  'What is the romanization for:',
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
                    child: _AnswerOptionButton(
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
                      state.currentIndex < practiceQuestions.length - 1
                          ? 'Next Question'
                          : 'See Results',
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

class _AnswerOptionButton extends StatelessWidget {
  final String label;
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback? onTap;

  const _AnswerOptionButton({
    required this.label,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    Color? backgroundColor;
    Color? borderColor;

    if (hasAnswered) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = brightness == Brightness.dark
              ? Colors.green.shade900
              : Colors.green.shade100;
          borderColor = Colors.green;
        } else {
          backgroundColor = brightness == Brightness.dark
              ? Colors.red.shade900
              : Colors.red.shade100;
          borderColor = Colors.red;
        }
      } else if (isCorrect) {
        backgroundColor = brightness == Brightness.dark
            ? Colors.green.shade900
            : Colors.green.shade100;
        borderColor = Colors.green;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasAnswered && (isSelected || isCorrect)
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: Spacing.m),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (hasAnswered && isCorrect)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
