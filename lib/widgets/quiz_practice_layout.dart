import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

/// A reusable scaffold-style layout for question-based flows (quizzes, drills,
/// flashcard practice, etc.). It enforces a consistent structure:
/// progress + score, title, prompt card, optional description, answer options,
/// optional feedback, and a bottom action button.
class QuizPracticeLayout extends StatelessWidget {
  const QuizPracticeLayout({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.scoreLabel,
    required this.title,
    required this.prompt,
    required this.answerOptions,
    this.answerDescription,
    this.feedback,
    this.bottomButton,
    this.promptExtras = const [],
    this.answerExtras = const [],
    this.progress,
    this.progressLabel,
    this.headerTrailing,
    this.padding = const EdgeInsets.all(Spacing.m),
    this.wrapPromptInCard = true,
    this.promptPadding,
    this.clipPromptInCard = false,
  });

  /// 1-based current question index for display.
  final int currentQuestion;

  /// Total number of questions in the session.
  final int totalQuestions;

  /// Text shown on the right side of the progress row (e.g. `Score: 3`).
  final String scoreLabel;

  /// Title presented under the progress row.
  final String title;

  /// Core prompt widget (character, word, etc.).
  final Widget prompt;

  /// Optional widgets inserted directly under the prompt card (hints, metadata).
  final List<Widget> promptExtras;

  /// Optional description displayed above the answer options.
  final Widget? answerDescription;

  /// Widgets representing the answer options.
  final List<Widget> answerOptions;

  /// Optional widgets shown between the answer list and feedback (stats, etc.).
  final List<Widget> answerExtras;

  /// Optional feedback widget (correct/incorrect message).
  final Widget? feedback;

  /// Button anchored near the bottom of the scroll view.
  final Widget? bottomButton;

  /// Override for progress bar value (defaults to computed ratio).
  final double? progress;

  /// Override for the progress label (defaults to `Question X of Y`).
  final String? progressLabel;

  /// Optional widget to replace the default score chip on the header row.
  final Widget? headerTrailing;

  /// Scroll padding for the layout content.
  final EdgeInsetsGeometry padding;

  /// Whether the prompt should be wrapped in a standard Tai card.
  final bool wrapPromptInCard;

  /// Whether the prompt card should clip its content.
  final bool clipPromptInCard;

  /// Optional padding applied inside the prompt card when wrapping.
  final EdgeInsetsGeometry? promptPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedProgress = _clampProgress(
      progress ?? _safeProgress(currentQuestion, totalQuestions),
    );
    final resolvedProgressLabel =
        progressLabel ?? 'Question $currentQuestion of $totalQuestions';

    return Column(
      children: [
        LinearProgressIndicator(
          value: resolvedProgress,
          minHeight: 8,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  progressLabel: resolvedProgressLabel,
                  scoreLabel: scoreLabel,
                  trailing: headerTrailing,
                ),
                const SizedBox(height: Spacing.m),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.m),
                _buildPrompt(context),
                ..._spacedWidgets(promptExtras),
                if (answerDescription != null) ...[
                  const SizedBox(height: Spacing.l),
                  answerDescription!,
                ],
                const SizedBox(height: Spacing.m),
                Column(
                  children: answerOptions
                      .map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.s),
                          child: option,
                        ),
                      )
                      .toList(),
                ),
                ..._spacedWidgets(answerExtras),
                if (feedback != null) ...[
                  const SizedBox(height: Spacing.l),
                  feedback!,
                ],
                if (bottomButton != null) ...[
                  const SizedBox(height: Spacing.l),
                  bottomButton!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrompt(BuildContext context) {
    if (!wrapPromptInCard) {
      return prompt;
    }
    return TaiCard.margin(
      padding: promptPadding ?? const EdgeInsets.symmetric(vertical: Spacing.l),
      clipBehavior: clipPromptInCard ? Clip.hardEdge : Clip.none,
      child: prompt,
    );
  }

  List<Widget> _spacedWidgets(List<Widget> widgets) {
    if (widgets.isEmpty) {
      return const [];
    }
    return [
      for (int i = 0; i < widgets.length; i++) ...[
        const SizedBox(height: Spacing.m),
        widgets[i],
      ],
    ];
  }

  double _safeProgress(int current, int total) {
    if (total <= 0) return 0;
    final ratio = current.clamp(0, total) / total;
    return ratio.isNaN ? 0 : ratio;
  }

  double _clampProgress(double value) {
    if (value.isNaN) return 0;
    if (value.isInfinite) {
      return value.isNegative ? 0 : 1;
    }
    return value.clamp(0.0, 1.0);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.progressLabel,
    required this.scoreLabel,
    this.trailing,
  });

  final String progressLabel;
  final String scoreLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            progressLabel,
            style: theme.textTheme.titleMedium,
          ),
        ),
        trailing ?? _ScoreChip(label: scoreLabel),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.l),
      ),
      child: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
