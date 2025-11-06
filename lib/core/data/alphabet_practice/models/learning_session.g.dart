// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningSession _$LearningSessionFromJson(Map<String, dynamic> json) =>
    LearningSession(
      sessionId: json['sessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      characterClass: json['characterClass'] as String,
      characterIds: (json['characterIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      questionsAnswered: (json['questionsAnswered'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LearningSessionToJson(LearningSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'characterClass': instance.characterClass,
      'characterIds': instance.characterIds,
      'questionsAnswered': instance.questionsAnswered,
      'correctAnswers': instance.correctAnswers,
    };
