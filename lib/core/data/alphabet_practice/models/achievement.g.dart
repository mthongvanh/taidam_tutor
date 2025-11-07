// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };

const _$AchievementTypeEnumMap = {
  AchievementType.firstPractice: 'firstPractice',
  AchievementType.perfectScore: 'perfectScore',
  AchievementType.dedicated: 'dedicated',
  AchievementType.committed: 'committed',
  AchievementType.learner: 'learner',
  AchievementType.scholar: 'scholar',
  AchievementType.consonantMaster: 'consonantMaster',
  AchievementType.vowelMaster: 'vowelMaster',
  AchievementType.weekWarrior: 'weekWarrior',
  AchievementType.monthlyMaster: 'monthlyMaster',
  AchievementType.centurion: 'centurion',
  AchievementType.expert: 'expert',
};
