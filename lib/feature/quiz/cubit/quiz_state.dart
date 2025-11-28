// --- Quiz States ---
import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/filter/filter_type.dart';
import 'package:taidam_tutor/feature/quiz/core/data/models/quiz_question.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  final FilterType selectedFilter;
  final List<FilterType> quizFilters;

  const QuizInitial({
    this.selectedFilter = FilterType.none,
    this.quizFilters = const [],
  });
  @override
  List<Object?> get props => [selectedFilter, quizFilters];
  QuizInitial copyWith({
    FilterType? selectedFilter,
    List<FilterType>? quizFilters,
  }) {
    return QuizInitial(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      quizFilters: quizFilters ?? this.quizFilters,
    );
  }
}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final QuizQuestion currentQuestion;
  final int? selectedAnswerIndex;
  final bool? isCorrect;
  final int score; // Optional: track score
  final FilterType selectedFilter;
  final List<FilterType> quizFilters;
  final double progress;
  final int currentQuestionNumber;
  final int totalQuestions;

  const QuizLoaded({
    required this.currentQuestion,
    this.selectedAnswerIndex,
    this.isCorrect,
    this.score = 0,
    this.selectedFilter = FilterType.none,
    this.quizFilters = const [],
    this.progress = 0.0,
    this.currentQuestionNumber = 0,
    this.totalQuestions = 0,
  });

  QuizLoaded copyWith({
    QuizQuestion? currentQuestion,
    int? selectedAnswerIndex,
    bool? isCorrect,
    bool clearSelectedAnswer =
        false, // Helper to nullify selectedAnswerIndex and isCorrect
    int? score,
    FilterType? selectedFilter,
    List<FilterType>? quizFilters,
    double? progress,
    int? currentQuestionNumber,
    int? totalQuestions,
  }) {
    return QuizLoaded(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      selectedAnswerIndex: clearSelectedAnswer
          ? null
          : (selectedAnswerIndex ?? this.selectedAnswerIndex),
      isCorrect: clearSelectedAnswer ? null : (isCorrect ?? this.isCorrect),
      score: score ?? this.score,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      quizFilters: quizFilters ?? this.quizFilters,
      progress: progress ?? this.progress,
      currentQuestionNumber:
          currentQuestionNumber ?? this.currentQuestionNumber,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  @override
  List<Object?> get props => [
        currentQuestion,
        selectedAnswerIndex,
        isCorrect,
        score,
        selectedFilter,
        quizFilters,
        progress,
        currentQuestionNumber,
        totalQuestions,
      ];
}

class QuizFinished extends QuizState {
  final int score;
  final String? image;

  const QuizFinished(this.score, {this.image});

  QuizFinished copyWith({
    int? score,
    String? image,
  }) {
    return QuizFinished(
      score ?? this.score,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [score];
}

class QuizError extends QuizState {
  final String message;
  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
