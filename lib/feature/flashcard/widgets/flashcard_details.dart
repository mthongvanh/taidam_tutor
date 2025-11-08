import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/flashcards/models/flashcard_model.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';

class FlaschardDetails extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback? onTap;

  const FlaschardDetails(
    this.flashcard, {
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TaiCard(
      child: InkWell(
        onTap: flashcard.audio?.isNotEmpty == true ? onTap : null,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (flashcard.audio?.isNotEmpty == true)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.play_circle),
                      onPressed: onTap,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        flashcard.question,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      _buildHints(flashcard),
                      Text(
                        flashcard.answer,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHints(Flashcard flashcard) {
    final sortedHints = List.from(flashcard.hints ?? [])
      ..sort((a, b) => (a.hintOrder ?? 999).compareTo(b.hintOrder ?? 999));

    return Column(
      spacing: 8,
      children: List.from(sortedHints.map((hint) {
        final label = hint.hintDisplayText ?? hint.type.name;
        return Text('$label: ${hint.content}');
      })),
    );
  }
}
