import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_cubit.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_state.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

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

              return ListView(
                children: [
                  _ScoreRow(state: state),
                  const SizedBox(height: Spacing.m),
                  Text(
                    'Which sound matches the highlighted word?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.m),
                  _WordPanel(state: state),
                  const SizedBox(height: Spacing.l),
                  ...question.soundOptions.indexed.map(
                    (entry) {
                      final idx = entry.$1;
                      final optionText = entry.$2;
                      final hasAnswered = state.selectedOptionIndex != null;

                      return Padding(
                        padding: EdgeInsets.only(bottom: Spacing.s),
                        child: AnswerOptionButton(
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
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Spacing.l),
                  FilledButton.icon(
                    onPressed: state.selectedOptionIndex != null
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
                ],
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Center(
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ),
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

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.state});

  final WordIdentificationState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progress: ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Score: ${state.totalCorrect}/${state.totalAnswered}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
