// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hint _$HintFromJson(Map<String, dynamic> json) => Hint(
      type: $enumDecode(_$HintTypeEnumMap, json['hintType']),
      content: json['content'] as String,
    );

Map<String, dynamic> _$HintToJson(Hint instance) => <String, dynamic>{
      'hintType': _$HintTypeEnumMap[instance.type]!,
      'content': instance.content,
    };

const _$HintTypeEnumMap = {
  HintType.soundIpa: 'soundIpa',
  HintType.lao: 'lao',
};
