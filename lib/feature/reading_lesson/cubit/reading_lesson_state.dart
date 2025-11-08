import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';

/// Enum representing the different stages of a reading lesson
enum LessonStage {
  goals,
  combinations,
  examples,
  practice,
  completed,
}

/// Base state for reading lesson
sealed class ReadingLessonState extends Equatable {
  const ReadingLessonState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReadingLessonInitial extends ReadingLessonState {
  const ReadingLessonInitial();
}

/// Loading state
class ReadingLessonLoading extends ReadingLessonState {
  const ReadingLessonLoading();
}

/// Active lesson state
class ReadingLessonActive extends ReadingLessonState {
  final ReadingLesson lesson;
  final LessonStage stage;
  final int currentIndex; // For combinations, examples, or practice questions
  final int? selectedAnswerIndex;
  final bool? isCorrect;
  final int score;
  final int totalPracticeQuestions;
  final List<PracticeQuestion>? practiceQuestions;

  const ReadingLessonActive({
    required this.lesson,
    required this.stage,
    this.currentIndex = 0,
    this.selectedAnswerIndex,
    this.isCorrect,
    this.score = 0,
    this.totalPracticeQuestions = 0,
    this.practiceQuestions,
  });

  ReadingLessonActive copyWith({
    ReadingLesson? lesson,
    LessonStage? stage,
    int? currentIndex,
    int? selectedAnswerIndex,
    bool? isCorrect,
    int? score,
    int? totalPracticeQuestions,
    List<PracticeQuestion>? practiceQuestions,
  }) {
    return ReadingLessonActive(
      lesson: lesson ?? this.lesson,
      stage: stage ?? this.stage,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswerIndex: selectedAnswerIndex,
      isCorrect: isCorrect,
      score: score ?? this.score,
      totalPracticeQuestions:
          totalPracticeQuestions ?? this.totalPracticeQuestions,
      practiceQuestions: practiceQuestions ?? this.practiceQuestions,
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        stage,
        currentIndex,
        selectedAnswerIndex,
        isCorrect,
        score,
        totalPracticeQuestions,
        practiceQuestions,
      ];
}

/// Lesson completed state
class ReadingLessonCompleted extends ReadingLessonState {
  final ReadingLesson lesson;
  final int score;
  final int totalQuestions;

  const ReadingLessonCompleted({
    required this.lesson,
    required this.score,
    required this.totalQuestions,
  });

  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  @override
  List<Object?> get props => [lesson, score, totalQuestions];
}

/// Error state
class ReadingLessonError extends ReadingLessonState {
  final String message;

  const ReadingLessonError(this.message);

  @override
  List<Object?> get props => [message];
}
