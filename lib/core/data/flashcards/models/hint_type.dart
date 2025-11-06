import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum HintType {
  /// Sound representation of the word in IPA format
  soundIpa,

  /// Laotian script representation of the word
  lao,
}
