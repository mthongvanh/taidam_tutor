import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/flashcards/models/flashcard_model.dart';

/// Represents a practice question generated from a flashcard
class PracticeQuestion extends Equatable {
  final Flashcard flashcard;
  final List<String> options;
  final int correctAnswerIndex;

  const PracticeQuestion({
    required this.flashcard,
    required this.options,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [flashcard, options, correctAnswerIndex];
}

/// Base state for flashcard practice
sealed class FlashcardPracticeState extends Equatable {
  const FlashcardPracticeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when practice hasn't started
class FlashcardPracticeInitial extends FlashcardPracticeState {
  const FlashcardPracticeInitial();
}

/// Loading state while fetching flashcards
class FlashcardPracticeLoading extends FlashcardPracticeState {
  const FlashcardPracticeLoading();
}

/// Active practice state with current question
class FlashcardPracticeActive extends FlashcardPracticeState {
  final PracticeQuestion currentQuestion;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int score;
  final int? selectedAnswerIndex;
  final bool? isCorrect;
  final bool showHint;

  const FlashcardPracticeActive({
    required this.currentQuestion,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.score,
    this.selectedAnswerIndex,
    this.isCorrect,
    this.showHint = false,
  });

  double get progress => (currentQuestionIndex + 1) / totalQuestions;

  FlashcardPracticeActive copyWith({
    PracticeQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? totalQuestions,
    int? score,
    int? selectedAnswerIndex,
    bool? isCorrect,
    bool? showHint,
  }) {
    return FlashcardPracticeActive(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      selectedAnswerIndex: selectedAnswerIndex,
      isCorrect: isCorrect,
      showHint: showHint ?? this.showHint,
    );
  }

  @override
  List<Object?> get props => [
        currentQuestion,
        currentQuestionIndex,
        totalQuestions,
        score,
        selectedAnswerIndex,
        isCorrect,
        showHint,
      ];
}

/// Practice completed state
class FlashcardPracticeCompleted extends FlashcardPracticeState {
  final int score;
  final int totalQuestions;

  const FlashcardPracticeCompleted({
    required this.score,
    required this.totalQuestions,
  });

  double get percentage => (score / totalQuestions) * 100;

  @override
  List<Object?> get props => [score, totalQuestions];
}

/// Error state
class FlashcardPracticeError extends FlashcardPracticeState {
  final String message;

  const FlashcardPracticeError(this.message);

  @override
  List<Object?> get props => [message];
}
