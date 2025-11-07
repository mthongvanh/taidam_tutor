import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/achievement.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';

sealed class CharacterDrillState extends Equatable {
  const CharacterDrillState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CharacterDrillInitial extends CharacterDrillState {
  const CharacterDrillInitial();
}

/// Loading state
class CharacterDrillLoading extends CharacterDrillState {
  const CharacterDrillLoading();
}

/// State when a question is being presented
class CharacterDrillQuestion extends CharacterDrillState {
  final Character targetCharacter;
  final List<Character> options;
  final int questionNumber;
  final int totalQuestions;
  final int correctAnswers;
  final int totalAttempts;

  const CharacterDrillQuestion({
    required this.targetCharacter,
    required this.options,
    required this.questionNumber,
    required this.totalQuestions,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
  });

  double get accuracy =>
      totalAttempts > 0 ? correctAnswers / totalAttempts : 0.0;

  @override
  List<Object?> get props => [
        targetCharacter,
        options,
        questionNumber,
        totalQuestions,
        correctAnswers,
        totalAttempts,
      ];
}

/// State when user has answered (showing feedback)
class CharacterDrillAnswered extends CharacterDrillState {
  final Character targetCharacter;
  final Character selectedCharacter;
  final List<Character> options;
  final bool isCorrect;
  final int questionNumber;
  final int totalQuestions;
  final int correctAnswers;
  final int totalAttempts;

  const CharacterDrillAnswered({
    required this.targetCharacter,
    required this.selectedCharacter,
    required this.options,
    required this.isCorrect,
    required this.questionNumber,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalAttempts,
  });

  double get accuracy =>
      totalAttempts > 0 ? correctAnswers / totalAttempts : 0.0;

  @override
  List<Object?> get props => [
        targetCharacter,
        selectedCharacter,
        options,
        isCorrect,
        questionNumber,
        totalQuestions,
        correctAnswers,
        totalAttempts,
      ];
}

/// State when drill is completed
class CharacterDrillCompleted extends CharacterDrillState {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final String characterClass;
  final List<Achievement> newlyUnlockedAchievements;

  const CharacterDrillCompleted({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.characterClass,
    this.newlyUnlockedAchievements = const [],
  });

  @override
  List<Object?> get props => [
        totalQuestions,
        correctAnswers,
        accuracy,
        characterClass,
        newlyUnlockedAchievements,
      ];
}

/// Error state
class CharacterDrillError extends CharacterDrillState {
  final String message;

  const CharacterDrillError(this.message);

  @override
  List<Object?> get props => [message];
}
