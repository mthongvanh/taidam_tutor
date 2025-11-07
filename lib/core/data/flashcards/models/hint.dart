import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taidam_tutor/core/data/flashcards/models/hint_type.dart';

part 'hint.g.dart';

// Represents a hint for a flashcard or quiz, which can be either an image or text.
@JsonSerializable(explicitToJson: true)
class Hint extends Equatable {
  /// The type of the hint
  @JsonKey(name: 'hintType')
  final HintType type;

  /// The content of the hint, which can be a URL for an image or text.
  final String content;

  /// Optional display text for the hint (user-friendly label)
  final String? hintDisplayText;

  /// Constructor for the Hint class.
  const Hint({
    required this.type,
    required this.content,
    this.hintDisplayText,
  });

  /// Creates a Hint instance from a JSON object.
  factory Hint.fromJson(Map<String, dynamic> json) => _$HintFromJson(json);

  /// Creates a JSON object from a Hint instance.
  Map<String, dynamic> toJson() => _$HintToJson(this);

  @override
  List<Object?> get props => [
        type,
        content,
        hintDisplayText,
      ];
}
