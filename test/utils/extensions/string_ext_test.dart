import 'package:flutter_test/flutter_test.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/utils/extensions/string_ext.dart';

Character _character({
  required int id,
  required String glyph,
  required CharacterClass characterClass,
  String? preComponent,
  String? postComponent,
  String? prePost,
}) {
  return Character(
    characterId: id,
    character: glyph,
    characterClass: characterClass,
    preComponent: preComponent,
    postComponent: postComponent,
    prePost: prePost,
  );
}

void main() {
  group('StringX.fromCharacters', () {
    test('returns empty string when no characters exist', () {
      expect(StringX.fromCharacters(const []), isEmpty);
    });

    test('returns glyph for single entries regardless of class', () {
      final vowel = _character(
        id: 1,
        glyph: 'ꪹ',
        characterClass: CharacterClass.vowel,
      );

      expect(StringX.fromCharacters([vowel]), 'ꪹ');
    });

    test('combines consonant with split vowel using pre and post components',
        () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪀ',
        characterClass: CharacterClass.consonant,
      );
      final vowel = _character(
        id: 2,
        glyph: 'ꪹ◌ꪷ',
        characterClass: CharacterClass.vowel,
        preComponent: 'ꪹ',
        postComponent: 'ꪷ',
      );

      final result = StringX.fromCharacters([consonant, vowel]);

      expect(result, 'ꪹꪀꪷ');
    });

    test('combines consonant with vowel that only has a post component', () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪁ',
        characterClass: CharacterClass.consonant,
      );
      final vowel = _character(
        id: 2,
        glyph: 'ꪫ',
        characterClass: CharacterClass.vowel,
        postComponent: 'ꪫ',
      );

      final result = StringX.fromCharacters([consonant, vowel]);

      expect(result, 'ꪁꪫ');
    });

    test(
        'falls back to consonant glyph based on character order when vowel has no split parts',
        () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪫ',
        characterClass: CharacterClass.consonant,
      );
      final vowel = _character(
        id: 2,
        glyph: 'ꪺ',
        characterClass: CharacterClass.vowel,
      );

      final result = StringX.fromCharacters([consonant, vowel]);

      expect(result, 'ꪫꪺ');
    });

    test('keeps standalone vowels and special glyphs intact', () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪃ',
        characterClass: CharacterClass.consonant,
      );
      final splitVowel = _character(
        id: 2,
        glyph: 'ꪹ◌ꪷ',
        characterClass: CharacterClass.vowel,
        preComponent: 'ꪹ',
        postComponent: 'ꪷ',
      );
      final standaloneVowel = _character(
        id: 3,
        glyph: 'ꪫ',
        characterClass: CharacterClass.vowel,
      );
      final special = _character(
        id: 4,
        glyph: '◌',
        characterClass: CharacterClass.special,
      );

      final result = StringX.fromCharacters(
        [consonant, splitVowel, standaloneVowel, special],
      );

      expect(result, 'ꪹꪃꪷꪫ◌');
    });

    test('keeps trailing consonant without any follower', () {
      final firstConsonant = _character(
        id: 1,
        glyph: 'ꪄ',
        characterClass: CharacterClass.consonant,
      );
      final vowel = _character(
        id: 2,
        glyph: 'ꪰ',
        characterClass: CharacterClass.vowel,
        postComponent: 'ꪰ',
      );
      final trailingConsonant = _character(
        id: 3,
        glyph: 'ꪅ',
        characterClass: CharacterClass.consonant,
      );

      final result = StringX.fromCharacters(
        [firstConsonant, vowel, trailingConsonant],
      );

      expect(result, 'ꪄꪰꪅ');
    });

    test(
        'does not skip characters that follow a consonant when they are not vowels',
        () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪆ',
        characterClass: CharacterClass.consonant,
      );
      final special = _character(
        id: 2,
        glyph: '꪿',
        characterClass: CharacterClass.special,
      );

      final result = StringX.fromCharacters([consonant, special]);

      expect(result, 'ꪆ꪿');
    });

    test('retains tone marker between split vowel components', () {
      final consonant = _character(
        id: 1,
        glyph: 'ꪋ',
        characterClass: CharacterClass.consonant,
      );
      final toneMarker = _character(
        id: 2,
        glyph: '꫁',
        characterClass: CharacterClass.unknown,
        prePost: 'post',
      );
      final splitVowel = _character(
        id: 3,
        glyph: 'ꪹ◌ꪱ',
        characterClass: CharacterClass.vowel,
        preComponent: 'ꪹ',
        postComponent: 'ꪱ',
      );

      final result =
          StringX.fromCharacters([consonant, toneMarker, splitVowel]);

      expect(result, 'ꪹꪋ꫁ꪱ');
    });
  });
}
