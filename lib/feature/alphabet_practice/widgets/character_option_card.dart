import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';

class CharacterOptionCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showFeedback;
  final bool isCorrect;

  const CharacterOptionCard({
    super.key,
    required this.character,
    required this.onTap,
    this.isSelected = false,
    this.showFeedback = false,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? backgroundColor;
    Color? borderColor;

    if (showFeedback && isSelected) {
      backgroundColor = isCorrect
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : theme.colorScheme.errorContainer.withOpacity(0.3);
      borderColor =
          isCorrect ? theme.colorScheme.primary : theme.colorScheme.error;
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      borderColor = theme.colorScheme.primary;
    }

    return InkWell(
      onTap: showFeedback ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
            width: borderColor != null ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/svg/${character.image}.svg',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              character.character,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (showFeedback && isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
