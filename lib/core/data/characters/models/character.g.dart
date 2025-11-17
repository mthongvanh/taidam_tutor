// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      characterId: (json['characterId'] as num).toInt(),
      character: json['character'] as String,
      characterClass: $enumDecode(
          _$CharacterClassEnumMap, json['characterClass'],
          unknownValue: CharacterClass.unknown),
      lao: json['lao'] as String?,
      romanization: json['romanization'] as String?,
      ipa: json['ipa'] as String?,
      position: json['position'] as String?,
      preComponent: json['preComponent'] as String?,
      postComponent: json['postComponent'] as String?,
      unicode: json['unicode'] as String?,
      audio: json['audio'] as String?,
      image: json['image'] as String?,
      example: json['example'] as String?,
      characterType: (json['characterType'] as num?)?.toInt(),
      highLow: json['highLow'] as String?,
      prePost: json['prePost'] as String?,
      regEx: json['regEx'] as String?,
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'characterId': instance.characterId,
      'character': instance.character,
      'lao': instance.lao,
      'romanization': instance.romanization,
      'ipa': instance.ipa,
      'position': instance.position,
      'preComponent': instance.preComponent,
      'postComponent': instance.postComponent,
      'unicode': instance.unicode,
      'audio': instance.audio,
      'image': instance.image,
      'example': instance.example,
      'characterType': instance.characterType,
      'highLow': instance.highLow,
      'prePost': instance.prePost,
      'characterClass': _$CharacterClassEnumMap[instance.characterClass]!,
      'regEx': instance.regEx,
    };

const _$CharacterClassEnumMap = {
  CharacterClass.consonant: 'consonant',
  CharacterClass.vowel: 'vowel',
  CharacterClass.special: 'special',
  CharacterClass.unknown: 'unknown',
};
