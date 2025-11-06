// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_mastery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterMastery _$CharacterMasteryFromJson(Map<String, dynamic> json) =>
    CharacterMastery(
      characterId: (json['characterId'] as num).toInt(),
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? 0,
      correctAttempts: (json['correctAttempts'] as num?)?.toInt() ?? 0,
      lastPracticed: DateTime.parse(json['lastPracticed'] as String),
      currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CharacterMasteryToJson(CharacterMastery instance) =>
    <String, dynamic>{
      'characterId': instance.characterId,
      'totalAttempts': instance.totalAttempts,
      'correctAttempts': instance.correctAttempts,
      'lastPracticed': instance.lastPracticed.toIso8601String(),
      'currentLevel': instance.currentLevel,
    };
