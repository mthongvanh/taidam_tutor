import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

part 'learning_session.g.dart';

@JsonSerializable(explicitToJson: true)
class LearningSession extends Equatable {
  /// Unique session identifier
  final String sessionId;

  /// When the session started
  final DateTime startTime;

  /// When the session ended (null if ongoing)
  final DateTime? endTime;

  /// Character class being practiced (consonant, vowel, etc.)
  @JsonKey(unknownEnumValue: CharacterClass.unknown)
  final CharacterClass characterClass;

  /// Character IDs included in this session
  final List<int> characterIds;

  /// Total questions answered
  final int questionsAnswered;

  /// Number of correct answers
  final int correctAnswers;

  const LearningSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.characterClass,
    required this.characterIds,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
  });

  /// Calculate session accuracy
  double get accuracy =>
      questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;

  /// Duration of the session
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Whether the session is still ongoing
  bool get isActive => endTime == null;

  /// Create a copy with updated values
  LearningSession copyWith({
    String? sessionId,
    DateTime? startTime,
    DateTime? endTime,
    CharacterClass? characterClass,
    List<int>? characterIds,
    int? questionsAnswered,
    int? correctAnswers,
  }) {
    return LearningSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      characterClass: characterClass ?? this.characterClass,
      characterIds: characterIds ?? this.characterIds,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  /// End the current session
  LearningSession endSession() {
    return copyWith(endTime: DateTime.now());
  }

  /// Record an answer
  LearningSession recordAnswer({required bool correct}) {
    return copyWith(
      questionsAnswered: questionsAnswered + 1,
      correctAnswers: correct ? correctAnswers + 1 : correctAnswers,
    );
  }

  factory LearningSession.fromJson(Map<String, dynamic> json) =>
      _$LearningSessionFromJson(json);

  Map<String, dynamic> toJson() => _$LearningSessionToJson(this);

  @override
  List<Object?> get props => [
        sessionId,
        startTime,
        endTime,
  characterClass,
        characterIds,
        questionsAnswered,
        correctAnswers,
      ];
}
