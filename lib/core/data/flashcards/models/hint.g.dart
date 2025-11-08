// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hint _$HintFromJson(Map<String, dynamic> json) => Hint(
      type: $enumDecode(_$HintTypeEnumMap, json['hintType']),
      content: json['content'] as String,
      hintDisplayText: json['hintDisplayText'] as String?,
      hintOrder: (json['hintOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HintToJson(Hint instance) => <String, dynamic>{
      'hintType': _$HintTypeEnumMap[instance.type]!,
      'content': instance.content,
      'hintDisplayText': instance.hintDisplayText,
      'hintOrder': instance.hintOrder,
    };

const _$HintTypeEnumMap = {
  HintType.soundIpa: 'soundIpa',
  HintType.romanization: 'romanization',
  HintType.lao: 'lao',
};
