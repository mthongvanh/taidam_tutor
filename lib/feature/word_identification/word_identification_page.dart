import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/core/services/word_identification_service.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_cubit.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_state.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

class WordIdentificationPage extends StatelessWidget {
  const WordIdentificationPage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordIdentificationCubit(),
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
                  _WordPanel(state: state),
                  const SizedBox(height: Spacing.m),
                  _ScoreRow(state: state),
                  const SizedBox(height: Spacing.m),
                  Text(
                    'Which sound matches the highlighted word?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.s),
                  ...question.soundOptions.indexed.map(
                    (entry) => _SoundOptionTile(
                      label: entry.$2,
                      index: entry.$1,
                      question: question,
                      state: state,
                      onTap:
                          context.read<WordIdentificationCubit>().selectOption,
                    ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap the matching sound from left to right.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.m),
            RichText(
              text: TextSpan(children: spans),
            ),
          ],
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

class _SoundOptionTile extends StatelessWidget {
  const _SoundOptionTile({
    required this.label,
    required this.index,
    required this.question,
    required this.state,
    required this.onTap,
  });

  final String label;
  final int index;
  final WordQuestion question;
  final WordIdentificationState state;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedOptionIndex == index;
    final hasAnswered = state.selectedOptionIndex != null;
    final isCorrectOption = question.correctOptionIndex == index;

    final colorScheme = Theme.of(context).colorScheme;
    Color? background;
    Color? foreground;

    if (hasAnswered) {
      if (isCorrectOption) {
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
      } else if (isSelected) {
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
      } else {
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurface;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      color: background,
      child: ListTile(
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: foreground,
              ),
        ),
        trailing: hasAnswered
            ? Icon(
                isCorrectOption
                    ? Icons.check_circle
                    : isSelected
                        ? Icons.cancel
                        : Icons.circle_outlined,
                color: isCorrectOption
                    ? colorScheme.primary
                    : isSelected
                        ? colorScheme.error
                        : colorScheme.outline,
              )
            : null,
        onTap: hasAnswered ? null : () => onTap(index),
      ),
    );
  }
}
