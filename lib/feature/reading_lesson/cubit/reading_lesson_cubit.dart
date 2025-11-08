import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';

class ReadingLessonCubit extends Cubit<ReadingLessonState> {
  final Random _random = Random();
  List<PracticeQuestion> _practiceQuestions = [];

  ReadingLessonCubit() : super(const ReadingLessonInitial());

  void startLesson(ReadingLesson lesson) {
    emit(ReadingLessonActive(
      lesson: lesson,
      stage: LessonStage.goals,
    ));
  }

  void proceedToNextStage() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;

    final lesson = currentState.lesson;

    switch (currentState.stage) {
      case LessonStage.goals:
        emit(currentState.copyWith(
          stage: LessonStage.combinations,
          currentIndex: 0,
        ));
        break;

      case LessonStage.combinations:
        if (lesson.examples != null && lesson.examples!.isNotEmpty) {
          emit(currentState.copyWith(
            stage: LessonStage.examples,
            currentIndex: 0,
          ));
        } else {
          _startPractice(lesson);
        }
        break;

      case LessonStage.examples:
        _startPractice(lesson);
        break;

      case LessonStage.practice:
        emit(ReadingLessonCompleted(
          lesson: lesson,
          score: currentState.score,
          totalQuestions: _practiceQuestions.length,
        ));
        break;

      case LessonStage.completed:
        break;
    }
  }

  void nextCombination() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.combinations) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < currentState.lesson.combinations.length) {
      emit(currentState.copyWith(currentIndex: nextIndex));
    } else {
      proceedToNextStage();
    }
  }

  void nextExample() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.examples) return;

    final examples = currentState.lesson.examples;
    if (examples == null) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < examples.length) {
      emit(currentState.copyWith(currentIndex: nextIndex));
    } else {
      proceedToNextStage();
    }
  }

  void _startPractice(ReadingLesson lesson) {
    // Generate practice questions from combinations
    _practiceQuestions = _generatePracticeQuestions(lesson.combinations);

    emit(ReadingLessonActive(
      lesson: lesson,
      stage: LessonStage.practice,
      currentIndex: 0,
      totalPracticeQuestions: _practiceQuestions.length,
      practiceQuestions: _practiceQuestions,
    ));
  }

  List<PracticeQuestion> _generatePracticeQuestions(
    List<Combination> combinations,
  ) {
    // Create a practice question for each combination
    return combinations.map((combination) {
      // Get 3 random wrong answers
      final wrongAnswers = <String>[];
      final otherCombinations = combinations
          .where((c) => c.romanization != combination.romanization)
          .toList()
        ..shuffle(_random);

      for (final combo in otherCombinations) {
        if (wrongAnswers.length >= 3) break;
        if (!wrongAnswers.contains(combo.romanization)) {
          wrongAnswers.add(combo.romanization);
        }
      }

      // Pad with placeholders if not enough unique answers
      while (wrongAnswers.length < 3) {
        wrongAnswers.add('Option ${wrongAnswers.length + 1}');
      }

      // Combine and shuffle
      final options = [combination.romanization, ...wrongAnswers]
        ..shuffle(_random);

      return PracticeQuestion(
        character: combination.result,
        options: options,
        correctAnswerIndex: options.indexOf(combination.romanization),
      );
    }).toList()
      ..shuffle(_random); // Shuffle question order
  }

  void selectAnswer(int answerIndex) {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.practice) return;
    if (currentState.selectedAnswerIndex != null) return; // Already answered

    final question = _practiceQuestions[currentState.currentIndex];
    final isCorrect = answerIndex == question.correctAnswerIndex;

    emit(currentState.copyWith(
      selectedAnswerIndex: answerIndex,
      isCorrect: isCorrect,
      score: isCorrect ? currentState.score + 1 : currentState.score,
    ));
  }

  void nextPracticeQuestion() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.practice) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < _practiceQuestions.length) {
      emit(currentState.copyWith(
        currentIndex: nextIndex,
        selectedAnswerIndex: null,
        isCorrect: null,
      ));
    } else {
      proceedToNextStage();
    }
  }

  void restartLesson() {
    final currentState = state;
    if (currentState is ReadingLessonCompleted) {
      startLesson(currentState.lesson);
    }
  }
}

/// Public practice question class for use in widgets
class PracticeQuestion {
  final String character;
  final List<String> options;
  final int correctAnswerIndex;

  const PracticeQuestion({
    required this.character,
    required this.options,
    required this.correctAnswerIndex,
  });
}
