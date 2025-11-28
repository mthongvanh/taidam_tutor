import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';

/// Reusable banner for showing correct/incorrect quiz feedback.
class QuizFeedbackBanner extends StatelessWidget {
  const QuizFeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.message,
    this.title,
    this.icon,
  });

  /// Whether the associated answer was correct.
  final bool isCorrect;

  /// Optional title displayed above the message. Defaults to a standard label.
  final String? title;

  /// Detailed feedback text describing the result.
  final String message;

  /// Optional icon to display. Defaults to a check or cancel glyph.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final displayTitle = title ??
        (isCorrect ? 'Correct! Great job!' : 'Not quite. Keep practicing.');
    final displayIcon = icon ??
        (isCorrect ? Icons.check_circle : Icons.cancel);

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(Spacing.l),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(displayIcon, color: color, size: 32),
          const SizedBox(width: Spacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
