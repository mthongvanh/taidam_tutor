import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

part 'character.g.dart';

@JsonSerializable(explicitToJson: true)
class Character extends Equatable {
  /// Sequential identifier for the entry in characters.json
  final int characterId;

  /// Primary Tai Dam character glyph stored in the JSON
  final String character;

  /// Lao script equivalent when available.
  final String? lao;

  /// Romanized representation (latin script).
  final String? romanization;

  /// International Phonetic Alphabet value.
  final String? ipa;

  /// Human readable explanation of the IPA pronunciation.
  final String? ipaDescription;

  /// Vowel placement metadata when applicable (before/after/above/etc.).
  final String? position;

  /// Optional split components for multi-part vowels.
  final String? preComponent;
  final String? postComponent;

  /// Unicode sequence (raw character string) used for matching.
  final String? unicode;

  /// audio file name, e.g. a1.mp3
  final String? audio;

  /// image of the character, e.g. svg filename
  final String? image;

  /// Example usage string present for vowels.
  final String? example;

  /// Character type flag from legacy data (vowel/consonant classification helper).
  final int? characterType;

  /// For consonants, whether it is high or low.
  final String? highLow;

  /// For vowels, whether it comes before or after the consonant.
  final String? prePost;

  //// Whether the character is a vowel, vowel-combo, consonant, or special character.
  @JsonKey(unknownEnumValue: CharacterClass.unknown)
  final CharacterClass characterClass;

  /// Regular expression for matching the character.
  final String? regEx;

  const Character({
    required this.characterId,
    required this.character,
    required this.characterClass,
    this.lao,
    this.romanization,
    this.ipa,
    this.ipaDescription,
    this.position,
    this.preComponent,
    this.postComponent,
    this.unicode,
    this.audio,
    this.image,
    this.example,
    this.characterType,
    this.highLow,
    this.prePost,
    this.regEx,
  });

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);

  @override
  List<Object?> get props => [
        characterId,
        character,
        lao,
        romanization,
        ipa,
        ipaDescription,
        position,
        preComponent,
        postComponent,
        unicode,
        audio,
        image,
        example,
        characterType,
        highLow,
        prePost,
        characterClass,
        regEx,
      ];
}
