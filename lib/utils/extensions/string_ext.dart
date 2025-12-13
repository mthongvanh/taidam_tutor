import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

/// Extension methods for String
extension StringX on String {
  static String fromCharacters(List<Character> characters) {
    final glyphs = characters.map((c) => c.character).toList();
    // for single characters, just return the glyph
    if (characters.length <= 1) {
      return glyphs.join();
    }

    // for multiple characters, handle vowel combinations specially
    final combined = StringBuffer();
    // tracks vowels we plan to output later (so tone marks can sit between parts)
    final deferredVowelOutputs = <int, _DeferredVowelOutput>{};

    for (var index = 0; index < characters.length; index++) {
      // write any deferred pieces scheduled for the current index first
      final deferred = deferredVowelOutputs.remove(index);
      if (deferred != null) {
        if (deferred.postComponent?.isNotEmpty ?? false) {
          combined.write(deferred.postComponent);
        }
        if (deferred.skipOriginalGlyph) {
          continue;
        }
      }

      final component = characters[index];

      if (component.characterClass == CharacterClass.consonant) {
        // find the next vowel that provides split glyph parts for this consonant
        final splitVowelMatch =
            _findSplitVowelMatch(characters, startIndex: index);
        if (splitVowelMatch != null) {
          if (splitVowelMatch.preComponent?.isNotEmpty ?? false) {
            combined.write(splitVowelMatch.preComponent);
          }
          combined.write(component.character);

          // delay writing the vowel's post component until we reach its index
          deferredVowelOutputs[splitVowelMatch.index] = _DeferredVowelOutput(
            postComponent: splitVowelMatch.postComponent,
            skipOriginalGlyph: true,
          );
          continue;
        }
      }

      combined.write(component.character);
    }
    return combined.toString();
  }
}

class _DeferredVowelOutput {
  /// Holds the text we need to emit at a later character index.
  const _DeferredVowelOutput({
    this.postComponent,
    this.skipOriginalGlyph = false,
  });

  final String? postComponent;
  final bool skipOriginalGlyph;
}

class _SplitVowelMatch {
  /// Describes a vowel that splits across a consonant (pre + post component).
  const _SplitVowelMatch({
    required this.index,
    this.preComponent,
    this.postComponent,
  });

  final int index;
  final String? preComponent;
  final String? postComponent;
}

_SplitVowelMatch? _findSplitVowelMatch(
  List<Character> characters, {
  required int startIndex,
}) {
  for (var i = startIndex + 1; i < characters.length; i++) {
    final candidate = characters[i];

    if (candidate.characterClass == CharacterClass.consonant) {
      // another consonant ends the search window
      break;
    }

    if (_isToneMarker(candidate)) {
      // tone markers can appear between consonant and vowel parts, so skip
      continue;
    }

    final hasComponents = (candidate.preComponent?.isNotEmpty ?? false) ||
        (candidate.postComponent?.isNotEmpty ?? false);
    if (candidate.characterClass == CharacterClass.vowel && hasComponents) {
      return _SplitVowelMatch(
        index: i,
        preComponent: candidate.preComponent,
        postComponent: candidate.postComponent,
      );
    }
  }
  return null;
}

bool _isToneMarker(Character character) {
  // tone markers are stored as "unknown" with positional metadata
  return character.characterClass == CharacterClass.unknown &&
      (character.prePost?.isNotEmpty ?? false);
}
