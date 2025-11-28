import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';

/// Reusable multiple-choice answer option styled after the flashcard practice
/// buttons so the various quiz/practice flows stay visually consistent.
class AnswerOptionButton extends StatelessWidget {
  final String label;
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback? onTap;
  final bool showCorrectIcon;

  const AnswerOptionButton({
    super.key,
    required this.label,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    this.onTap,
    this.showCorrectIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    Color? backgroundColor;
    Color? borderColor;
    IconData? feedbackIcon;
    Color? feedbackColor;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = brightness == Brightness.dark
            ? Colors.green.shade900.withAlpha(100)
            : Colors.green.shade50;
        borderColor = Colors.green;
        feedbackIcon = Icons.check_circle;
        feedbackColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = brightness == Brightness.dark
            ? Colors.red.shade900.withAlpha(100)
            : Colors.red.shade50;
        borderColor = Colors.red;
        feedbackIcon = Icons.cancel;
        feedbackColor = Colors.red;
      }
    }

    final resolvedBackground = backgroundColor ?? theme.colorScheme.surface;
    final resolvedBorder = borderColor ?? theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: resolvedBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resolvedBorder, width: 2),
          boxShadow: [
            if (!hasAnswered)
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: Spacing.m),
            Expanded(
              child: Text(
                option,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (showCorrectIcon && hasAnswered && feedbackIcon != null) ...[
              SizedBox(width: Spacing.s),
              Icon(
                feedbackIcon,
                color: feedbackColor,
                size: 28,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
