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
    String combined = '';
    final charactersAdded = <int>[];
    for (final character in characters.indexed) {
      if (charactersAdded.contains(character.$1)) {
        // already processed as part of a previous combination
        continue;
      }

      final component = character.$2;
      if (component.characterClass == CharacterClass.consonant) {
        // for consonants, we need to check the next character to see if it's a vowel
        // that modifies the consonant glyph
        final nextIndex = character.$1 + 1;
        if (nextIndex < characters.length) {
          final nextComponent = characters[nextIndex];
          if (nextComponent.characterClass == CharacterClass.vowel) {
            // mark the next character as added only when it is part of the combination
            charactersAdded.add(nextIndex);
            // there is a next character. Check if it's a vowel that modifies this consonant
            // e.g., a consonant followed by a vowel with pre/post components
            // The logic is:
            // - If the vowel has a pre-component, prepend it to the consonant glyph
            // - If the vowel has a post-component, append it to the consonant glyph
            if (nextComponent.preComponent?.isNotEmpty ?? false) {
              combined += nextComponent.preComponent!;
            }
            if (nextComponent.postComponent?.isNotEmpty ?? false) {
              combined +=
                  "${component.character}${nextComponent.postComponent ?? ''}";
            } else {
              combined += component.character;
            }
            continue;
          }
        }
        // if there is no vowel partner, keep the consonant glyph as-is
        combined += component.character;
      } else {
        // Standalone vowel or vowel not following a consonant: include its glyph
        combined += component.character;
      }
    }
    return combined;
  }
}
