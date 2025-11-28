import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_cubit.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_state.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

class WordIdentificationPage extends StatelessWidget {
  const WordIdentificationPage({
    super.key,
    this.title,
    this.presetGlyphs,
  });

  final String? title;
  final List<String>? presetGlyphs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordIdentificationCubit(presetGlyphs: presetGlyphs),
      child: _WordIdentificationView(title: title),
    );
  }
}

class _WordIdentificationView extends StatelessWidget {
  const _WordIdentificationView({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Word Identification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.m),
          child: BlocBuilder<WordIdentificationCubit, WordIdentificationState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage != null) {
                return TaiError(
                  errorMessage: state.errorMessage,
                  onRetry:
                      context.read<WordIdentificationCubit>().loadChallenge,
                );
              }

              final question = state.currentQuestion;
              if (question == null) {
                return TaiError(
                  errorMessage: 'No challenge data available.',
                  onRetry:
                      context.read<WordIdentificationCubit>().loadChallenge,
                );
              }

              final hasAnswered = state.selectedOptionIndex != null;

              return QuizPracticeLayout(
                currentQuestion: state.currentQuestionIndex + 1,
                totalQuestions: state.totalQuestions,
                scoreLabel:
                    'Score: ${state.totalCorrect}/${state.totalAnswered}',
                title: 'Which sound matches the highlighted word?',
                prompt: _WordPanel(state: state),
                answerDescription: Text(
                  'Tap the sound that matches the highlighted glyph.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                answerOptions: question.soundOptions.indexed.map(
                  (entry) {
                    final idx = entry.$1;
                    final optionText = entry.$2;
                    return AnswerOptionButton(
                      label: String.fromCharCode(65 + idx),
                      option: optionText,
                      isSelected: state.selectedOptionIndex == idx,
                      isCorrect: question.correctOptionIndex == idx,
                      hasAnswered: hasAnswered,
                      onTap: hasAnswered
                          ? null
                          : () => context
                              .read<WordIdentificationCubit>()
                              .selectOption(idx),
                    );
                  },
                ).toList(),
                feedback: hasAnswered
                    ? _WordIdentificationFeedback(
                        isCorrect: state.selectedOptionIndex ==
                            question.correctOptionIndex,
                        correctAnswer:
                            question.soundOptions[question.correctOptionIndex],
                      )
                    : null,
                bottomButton: FilledButton.icon(
                  onPressed: hasAnswered
                      ? context.read<WordIdentificationCubit>().nextWord
                      : null,
                  icon: Icon(
                    state.currentQuestionIndex == state.totalQuestions - 1
                        ? Icons.refresh
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    state.currentQuestionIndex == state.totalQuestions - 1
                        ? 'New Challenge'
                        : 'Next Word',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WordPanel extends StatelessWidget {
  const _WordPanel({required this.state});

  final WordIdentificationState state;

  @override
  Widget build(BuildContext context) {
    final spans = _buildGlyphSpans(context, state);

    return Center(
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }

  List<InlineSpan> _buildGlyphSpans(
    BuildContext context,
    WordIdentificationState state,
  ) {
    final theme = Theme.of(context);
    final highlightStyle = theme.textTheme.displaySmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w700,
    );
    final baseStyle = theme.textTheme.displaySmall;

    final challenge = state.challenge;
    if (challenge == null) return [];

    return challenge.questions.indexed
        .map(
          (entry) => TextSpan(
            text: entry.$2.segment.glyph,
            style: entry.$1 == state.currentQuestionIndex
                ? highlightStyle
                : baseStyle,
          ),
        )
        .toList();
  }
}

class _WordIdentificationFeedback extends StatelessWidget {
  const _WordIdentificationFeedback({
    required this.isCorrect,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(Spacing.m),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
          ),
          const SizedBox(width: Spacing.s),
          Expanded(
            child: Text(
              isCorrect ? 'Correct!' : 'Correct sound: $correctAnswer',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
