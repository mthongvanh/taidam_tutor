import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/flashcards/flashcard_repository.dart';
import 'package:taidam_tutor/core/data/flashcards/models/flashcard_model.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/flashcard/cubit/flashcard_practice_state.dart';

class FlashcardPracticeCubit extends Cubit<FlashcardPracticeState> {
  final FlashcardRepository _repository;
  final Random _random = Random();

  List<PracticeQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  FlashcardPracticeCubit()
      : _repository = DependencyManager().get<FlashcardRepository>(),
        super(const FlashcardPracticeInitial()) {
    _loadPractice();
  }

  Future<void> _loadPractice() async {
    emit(const FlashcardPracticeLoading());

    try {
      final flashcards = await _repository.getFlashcards();

      if (flashcards.isEmpty) {
        emit(const FlashcardPracticeError('No flashcards available'));
        return;
      }

      // Generate practice questions (limit to 10 for a manageable session)
      _questions =
          _generatePracticeQuestions(flashcards, min(10, flashcards.length));
      _currentIndex = 0;
      _score = 0;

      _emitCurrentQuestion();
    } catch (e) {
      emit(FlashcardPracticeError('Failed to load flashcards: $e'));
    }
  }

  List<PracticeQuestion> _generatePracticeQuestions(
    List<Flashcard> flashcards,
    int count,
  ) {
    final shuffled = List<Flashcard>.from(flashcards)..shuffle(_random);
    final selected = shuffled.take(count).toList();

    return selected.map((flashcard) {
      return _createPracticeQuestion(flashcard, flashcards);
    }).toList();
  }

  PracticeQuestion _createPracticeQuestion(
    Flashcard correctFlashcard,
    List<Flashcard> allFlashcards,
  ) {
    // Get the correct answer
    final correctAnswer = correctFlashcard.answer;

    // Get 3 random wrong answers
    final wrongAnswers = <String>[];
    final otherFlashcards = allFlashcards
        .where((f) => f.answer != correctAnswer)
        .toList()
      ..shuffle(_random);

    for (final flashcard in otherFlashcards) {
      if (wrongAnswers.length >= 3) break;
      if (!wrongAnswers.contains(flashcard.answer)) {
        wrongAnswers.add(flashcard.answer);
      }
    }

    // If we don't have enough unique wrong answers, pad with placeholder
    while (wrongAnswers.length < 3) {
      wrongAnswers.add('Option ${wrongAnswers.length + 1}');
    }

    // Combine and shuffle all options
    final options = [correctAnswer, ...wrongAnswers]..shuffle(_random);
    final correctAnswerIndex = options.indexOf(correctAnswer);

    return PracticeQuestion(
      flashcard: correctFlashcard,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  void _emitCurrentQuestion() {
    if (_currentIndex >= _questions.length) {
      emit(FlashcardPracticeCompleted(
        score: _score,
        totalQuestions: _questions.length,
      ));
      return;
    }

    emit(FlashcardPracticeActive(
      currentQuestion: _questions[_currentIndex],
      currentQuestionIndex: _currentIndex,
      totalQuestions: _questions.length,
      score: _score,
    ));
  }

  void selectAnswer(int answerIndex) {
    final currentState = state;
    if (currentState is! FlashcardPracticeActive) return;
    if (currentState.selectedAnswerIndex != null) return; // Already answered

    final isCorrect =
        answerIndex == currentState.currentQuestion.correctAnswerIndex;

    if (isCorrect) {
      _score++;
    }

    emit(currentState.copyWith(
      selectedAnswerIndex: answerIndex,
      isCorrect: isCorrect,
    ));
  }

  void nextQuestion() {
    _currentIndex++;
    _emitCurrentQuestion();
  }

  void toggleHint() {
    final currentState = state;
    if (currentState is! FlashcardPracticeActive) return;

    emit(currentState.copyWith(showHint: !currentState.showHint));
  }

  void resetPractice() {
    _loadPractice();
  }
}
