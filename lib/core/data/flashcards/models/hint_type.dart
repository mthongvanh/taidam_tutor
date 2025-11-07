import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum HintType {
  /// Sound representation of the word in IPA format
  soundIpa,

  /// Romanization of the word
  romanization,

  /// Laotian script representation of the word
  lao,
}
