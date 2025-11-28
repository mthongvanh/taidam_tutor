import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';

/// Reusable multiple-choice answer option.
///
/// Handles highlighting for selected/correct/incorrect states so quiz and
/// practice flows stay visually consistent across the app.
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

    Color backgroundColor = theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outline;
    Color circleColor = theme.colorScheme.primary;

    if (hasAnswered) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = brightness == Brightness.dark
              ? Colors.green.shade900
              : Colors.green.shade100;
          borderColor = Colors.green;
          circleColor = Colors.green;
        } else {
          backgroundColor = brightness == Brightness.dark
              ? Colors.red.shade900
              : Colors.red.shade100;
          borderColor = Colors.red;
          circleColor = Colors.red;
        }
      } else if (isCorrect) {
        backgroundColor = brightness == Brightness.dark
            ? Colors.green.shade900
            : Colors.green.shade100;
        borderColor = Colors.green;
        circleColor = Colors.green;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
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
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (showCorrectIcon && hasAnswered && isCorrect)
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
