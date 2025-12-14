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
  int _totalPracticeQuestionsOverall = 0;

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
      _totalPracticeQuestionsOverall = 0;

      emit(ReadingLessonActive(
        lesson: lesson,
        stage: LessonStage.goalOverview,
        currentGoalIndex: 0,
        activeCombinations: _combinationsForGoal(lesson, 0),
        activeExamples: _examplesForGoal(lesson, 0),
      ));
    } catch (error) {
      emit(
          const ReadingLessonError('Failed to load lesson. Please try again.'));
    }
  }

  void proceedToNextStage() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;

    switch (currentState.stage) {
      case LessonStage.goalOverview:
        _advanceFromGoalOverview(currentState);
        break;

      case LessonStage.goalCombinations:
        if (currentState.activeExamples.isNotEmpty) {
          emit(currentState.copyWith(
            stage: LessonStage.goalExamples,
            currentIndex: 0,
          ));
        } else {
          _startPractice(currentState);
        }
        break;

      case LessonStage.goalExamples:
        _startPractice(currentState);
        break;

      case LessonStage.goalPractice:
        _advanceToNextGoalOrComplete(currentState);
        break;

      case LessonStage.completed:
        break;
    }
  }

  void nextCombination() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.goalCombinations) return;

    final combinations = currentState.activeCombinations;
    if (combinations.isEmpty) {
      proceedToNextStage();
      return;
    }

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < combinations.length) {
      emit(currentState.copyWith(currentIndex: nextIndex));
    } else {
      proceedToNextStage();
    }
  }

  void nextExample() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.goalExamples) return;

    final examples = currentState.activeExamples;
    if (examples.isEmpty) {
      proceedToNextStage();
      return;
    }

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex < examples.length) {
      emit(currentState.copyWith(currentIndex: nextIndex));
    } else {
      proceedToNextStage();
    }
  }

  void skipToPractice() {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    _startPractice(currentState);
  }

  void _startPractice(ReadingLessonActive currentState) {
    // Generate practice questions from combinations and matching examples
    final practiceItems = _buildPracticeItems(
      currentState.activeCombinations,
      currentState.activeExamples,
    );

    if (practiceItems.isEmpty) {
      _advanceToNextGoalOrComplete(currentState);
      return;
    }

    _practiceQuestions = _generatePracticeQuestions(practiceItems);
    _totalPracticeQuestionsOverall += _practiceQuestions.length;

    emit(currentState.copyWith(
      stage: LessonStage.goalPractice,
      currentIndex: 0,
      totalPracticeQuestions: _totalPracticeQuestionsOverall,
      selectedAnswerIndex: null,
      isCorrect: null,
      practiceQuestions: _practiceQuestions,
    ));
  }

  List<PracticeQuestion> _generatePracticeQuestions(
    List<_PracticeItem> practiceItems,
  ) {
    // Create a practice question for each practice item
    return practiceItems.map((item) {
      final wrongAnswers = practiceItems
          .where((candidate) => candidate != item)
          .map((candidate) => candidate.answer)
          .toList()
        ..shuffle(_random);

      final options = <String>[item.answer];

      for (final answer in wrongAnswers) {
        if (options.length >= 4) break;
        if (!options.contains(answer)) {
          options.add(answer);
        }
      }

      options.shuffle(_random);

      return PracticeQuestion(
        character: item.prompt,
        options: options,
        correctAnswerIndex: options.indexOf(item.answer),
      );
    }).toList()
      ..shuffle(_random); // Shuffle question order
  }

  void selectAnswer(int answerIndex) {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (currentState.stage != LessonStage.goalPractice) return;
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
    if (currentState.stage != LessonStage.goalPractice) return;

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

  void selectGoal(int goalIndex) {
    final currentState = state;
    if (currentState is! ReadingLessonActive) return;
    if (goalIndex < 0 || goalIndex >= currentState.lesson.goals.length) {
      return;
    }

    _practiceQuestions = [];
    _totalPracticeQuestionsOverall = 0;

    emit(currentState.copyWith(
      stage: LessonStage.goalOverview,
      currentGoalIndex: goalIndex,
      currentIndex: 0,
      score: 0,
      totalPracticeQuestions: 0,
      selectedAnswerIndex: null,
      isCorrect: null,
      activeCombinations: _combinationsForGoal(currentState.lesson, goalIndex),
      activeExamples: _examplesForGoal(currentState.lesson, goalIndex),
      practiceQuestions: const [],
    ));
  }

  void _advanceFromGoalOverview(ReadingLessonActive currentState) {
    if (currentState.activeCombinations.isNotEmpty) {
      emit(currentState.copyWith(
        stage: LessonStage.goalCombinations,
        currentIndex: 0,
      ));
    } else if (currentState.activeExamples.isNotEmpty) {
      emit(currentState.copyWith(
        stage: LessonStage.goalExamples,
        currentIndex: 0,
      ));
    } else {
      _startPractice(currentState);
    }
  }

  void _advanceToNextGoalOrComplete(ReadingLessonActive currentState) {
    final nextGoalIndex = currentState.currentGoalIndex + 1;
    if (nextGoalIndex < currentState.lesson.goals.length) {
      emit(ReadingLessonActive(
        lesson: currentState.lesson,
        stage: LessonStage.goalOverview,
        score: currentState.score,
        totalPracticeQuestions: _totalPracticeQuestionsOverall,
        currentGoalIndex: nextGoalIndex,
        activeCombinations:
            _combinationsForGoal(currentState.lesson, nextGoalIndex),
        activeExamples: _examplesForGoal(currentState.lesson, nextGoalIndex),
      ));
    } else {
      emit(ReadingLessonCompleted(
        lesson: currentState.lesson,
        score: currentState.score,
        totalQuestions: _totalPracticeQuestionsOverall,
      ));
    }
  }

  List<Combination> _combinationsForGoal(
    ReadingLesson lesson,
    int goalIndex,
  ) {
    final goal = lesson.goals[goalIndex];
    return lesson.combinations
        .where(
          (combination) => _matchesGoalCharacters(combination.characters, goal),
        )
        .toList();
  }

  List<Example> _examplesForGoal(
    ReadingLesson lesson,
    int goalIndex,
  ) {
    final goal = lesson.goals[goalIndex];
    final examples = lesson.examples ?? const <Example>[];
    return examples
        .where(
          (example) => _matchesGoalCharacters(example.characters, goal),
        )
        .toList();
  }

  List<_PracticeItem> _buildPracticeItems(
    List<Combination> combinations,
    List<Example> examples,
  ) {
    final rawItems = <_PracticeItem>[
      for (final combination in combinations)
        _PracticeItem(
          prompt: combination.result,
          answer: combination.practiceDescription,
        ),
      for (final example in examples)
        _PracticeItem(
          prompt: example.displayWord,
          answer: example.displayRomanization,
        ),
    ];

    final seenKeys = <String>{};
    final filteredItems = <_PracticeItem>[];

    for (final item in rawItems) {
      final prompt = item.prompt.trim();
      final answer = item.answer.trim();
      if (prompt.isEmpty || answer.isEmpty) {
        continue;
      }

      final key = '$prompt::$answer';
      if (seenKeys.add(key)) {
        filteredItems.add(item);
      }
    }

    return filteredItems;
  }

  bool _matchesGoalCharacters(
    LessonCharacterSet source,
    LessonGoal goal,
  ) {
    final goalIds = goal.characters.characterIds;
    if (goalIds.isEmpty) {
      return false;
    }
    final goalSet = goalIds.toSet();
    final sourceSet = source.characterIds.toSet();
    return goalSet.every(sourceSet.contains);
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

class _PracticeItem {
  final String prompt;
  final String answer;

  const _PracticeItem({
    required this.prompt,
    required this.answer,
  });
}
