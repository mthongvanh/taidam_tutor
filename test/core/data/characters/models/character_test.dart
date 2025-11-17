import 'package:flutter_test/flutter_test.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

void main() {
  group('Character Model', () {
    Character createSampleCharacter() {
      return Character(
        characterId: 1,
  character: 'ꪼ',
  characterClass: CharacterClass.vowel,
        lao: 'ເ-ີ',
        romanization: 'o',
        ipa: '/ə/',
        position: 'split',
        preComponent: 'ꪹ',
        postComponent: 'ꪷ',
        unicode: 'ꪹꪷ',
        audio: 'a1',
        image: 'character.svg',
        example: 'ꪼ◌',
        characterType: 0,
        highLow: 'high',
        prePost: 'before',
        regEx: '\\uaab9.{1}\\uaab7',
      );
    }

    test('fromJson maps Tai Dam field and metadata correctly', () {
      final json = {
        'characterId': 2,
        'character': 'ꪹ',
        'lao': 'ໂ-,-ົ-',
        'romanization': 'aw',
        'ipa': '/o/',
        'position': 'before',
        'preComponent': 'ꪹ',
        'postComponent': null,
        'unicode': 'ꪹ',
        'audio': 'a2',
        'image': 'character2.svg',
        'example': 'ꪹ◌',
        'characterType': 1,
        'characterClass': 'vowel',
        'highLow': 'low',
        'prePost': 'post',
        'regEx': '\\uaab9',
      };

      final character = Character.fromJson(json);

      expect(character.characterId, 2);
      expect(character.character, 'ꪹ');
      expect(character.lao, 'ໂ-,-ົ-');
      expect(character.romanization, 'aw');
      expect(character.ipa, '/o/');
      expect(character.position, 'before');
      expect(character.preComponent, 'ꪹ');
      expect(character.postComponent, isNull);
      expect(character.unicode, 'ꪹ');
      expect(character.audio, 'a2');
      expect(character.image, 'character2.svg');
      expect(character.example, 'ꪹ◌');
  expect(character.characterType, 1);
  expect(character.characterClass, CharacterClass.vowel);
      expect(character.highLow, 'low');
      expect(character.prePost, 'post');
      expect(character.regEx, '\\uaab9');
    });

    test('fromJson falls back to character field when Tai Dam missing', () {
      final json = {
        'characterId': 99,
        'character': 'ꫛ',
        'characterClass': 'special',
        'characterType': 1,
        'romanization': 'kon',
      };

      final character = Character.fromJson(json);

      expect(character.characterId, 99);
  expect(character.character, 'ꫛ');
  expect(character.characterClass, CharacterClass.special);
      expect(character.characterType, 1);
      expect(character.romanization, 'kon');
    });

    test('toJson returns a valid JSON map using taiDam key', () {
      final character = createSampleCharacter();

      final json = character.toJson();

      expect(json['characterId'], 1);
      expect(json['character'], 'ꪼ');
      expect(json['lao'], 'ເ-ີ');
      expect(json['romanization'], 'o');
      expect(json['ipa'], '/ə/');
      expect(json['position'], 'split');
      expect(json['preComponent'], 'ꪹ');
      expect(json['postComponent'], 'ꪷ');
      expect(json['unicode'], 'ꪹꪷ');
      expect(json['audio'], 'a1');
      expect(json['image'], 'character.svg');
      expect(json['example'], 'ꪼ◌');
      expect(json['romanization'], 'o');
      expect(json['characterType'], 0);
      expect(json['characterClass'], 'vowel');
      expect(json['highLow'], 'high');
      expect(json['prePost'], 'before');
      expect(json['regEx'], '\\uaab9.{1}\\uaab7');
    });

    test('equality operator returns true for identical objects', () {
      final character1 = createSampleCharacter();
      final character2 = createSampleCharacter();

      expect(character1, character2);
    });

    test('equality operator returns false for different objects', () {
      final character1 = createSampleCharacter();
      final character2 = Character(
        characterId: 3,
        character: 'ꪺ',
        characterClass: CharacterClass.vowel,
        audio: 'a3',
        image: 'character3.svg',
        example: 'ꪺ◌',
        romanization: 'uh',
        characterType: 1,
      );

      expect(character1, isNot(character2));
    });

    test('handles null highLow and prePost values correctly', () {
      final json = {
        'characterId': 4,
        'character': 'ꪮ',
        'audio': 'a4',
        'image': 'character4.svg',
        'characterType': 1,
        'characterClass': 'consonant',
        'regEx': null,
      };

      final character = Character.fromJson(json);

      expect(character.highLow, isNull);
      expect(character.prePost, isNull);
      expect(character.example, isNull);
      expect(character.characterClass, CharacterClass.consonant);
    });
  });
}
