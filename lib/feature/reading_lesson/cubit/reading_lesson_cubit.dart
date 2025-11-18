import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';

class ReadingLessonCubit extends Cubit<ReadingLessonState> {
  final Random _random = Random();
  List<PracticeQuestion> _practiceQuestions = [];
  final CharacterRepository _characterRepository;
  Map<String, dynamic>? _currentLessonData;

  ReadingLessonCubit({CharacterRepository? characterRepository})
      : _characterRepository =
            characterRepository ?? dm.get<CharacterRepository>(),
        super(const ReadingLessonInitial());

  Future<void> startLesson(Map<String, dynamic> lessonData) async {
    _currentLessonData = lessonData;
    emit(const ReadingLessonLoading());

    try {
      final characters = await _characterRepository.getCharacters();
      final characterMap = {
        for (final character in characters) character.characterId: character
      };

      final lesson = ReadingLesson.fromJson(lessonData, characterMap);

      _practiceQuestions = [];

      emit(ReadingLessonActive(
        lesson: lesson,
        stage: LessonStage.goals,
      ));
    } catch (error) {
      emit(const ReadingLessonError('Failed to load lesson. Please try again.'));
    }
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
      final wrongAnswers = combinations
          .where((c) => c != combination)
          .map((c) => c.practiceDescription)
          .toList()
        ..shuffle(_random);

      final options = <String>[combination.practiceDescription];

      for (final answer in wrongAnswers) {
        if (options.length >= 4) break;
        if (!options.contains(answer)) {
          options.add(answer);
        }
      }

      while (options.length < 4) {
        options.add('Review the lesson content');
      }

      options.shuffle(_random);

      return PracticeQuestion(
        character: combination.result,
        options: options,
        correctAnswerIndex: options.indexOf(combination.practiceDescription),
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
    final data = _currentLessonData;
    if (data == null) return;
    startLesson(data);
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
