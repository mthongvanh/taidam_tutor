import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/filter/filter_type.dart';
import 'package:taidam_tutor/feature/quiz/core/data/models/quiz_question.dart';
import 'package:taidam_tutor/feature/quiz/core/utils/character_quiz_question_generator.dart';
import 'package:taidam_tutor/feature/quiz/cubit/quiz_state.dart';

enum QuizMode { character }

// --- Quiz Cubit ---
class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(QuizInitial()) {
    initQuiz();
  }

  QuizMode mode = QuizMode.character;

  // Sample questions - replace with your actual data source
  final List<QuizQuestion> _allQuestions = [];

  int _currentQuestionIndex = 0;
  int _currentScore = 0;

  final List<FilterType> _quizFilters = FilterType.values;
  List<FilterType> get quizFilters => _quizFilters;

  FilterType _selectedFilter = FilterType.none;

  void initQuiz() {
    emit(QuizInitial());

    _currentQuestionIndex = 0;
    _currentScore = 0;

    createQuestions(_selectedFilter);
    // Load the first question
    loadQuestion(_selectedFilter);
  }

  void updateFilter(String filter) {
    // This function can be used to update the filter for the quiz
    // For example, you can fetch questions based on the selected filter
    // and then call loadQuestion() to refresh the quiz.
    _selectedFilter = FilterType.fromString(filter);
    resetQuiz();
  }

  void createQuestions([FilterType filter = FilterType.none]) async {
    final questions = <QuizQuestion>[];
    switch (mode) {
      case QuizMode.character:
        final characters =
            await CharacterQuizQuestionGenerator().generateQuestions(
          filter: filter,
        );
        questions.addAll(characters);
        break;
      // Add more cases for different quiz modes if needed
    }

    _allQuestions.clear();
    _allQuestions.addAll(questions);
  }

  Future<void> loadQuestion(FilterType filter) async {
    emit(QuizLoading());
    try {
      // Simulate network delay or actual data fetching
      await Future.delayed(const Duration(milliseconds: 500));
      if (_currentQuestionIndex < _allQuestions.length) {
        emit(
          QuizLoaded(
            currentQuestion: _allQuestions[_currentQuestionIndex],
            progress:
                (_currentQuestionIndex + 1) / _allQuestions.length.toDouble(),
            currentQuestionNumber: _currentQuestionIndex + 1,
            totalQuestions: _allQuestions.length,
            score: _currentScore,
            quizFilters: _quizFilters,
            selectedFilter: filter,
          ),
        );
      } else {
        if (_allQuestions.isEmpty) {
          emit(QuizError('No questions available for the selected filter.'));
          return;
        }
        // No more questions - could emit a QuizFinished state
        emit(
          QuizFinished(
            _currentScore,
            image: _imageForScore(
              _currentScore / _allQuestions.length.toDouble(),
            ),
          ),
        );
      }
    } catch (e) {
      emit(QuizError('Failed to load question: ${e.toString()}'));
    }
  }

  String _imageForScore(double percentage) {
    if (percentage > 0.8) {
      return 'assets/images/png/jump-joy.png';
    } else if (percentage > 0.5) {
      return 'assets/images/png/studying.png';
    } else {
      return 'assets/images/png/sad-face.png';
    }
  }

  void selectAnswer(int index) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final bool isCorrect =
          index == currentState.currentQuestion.correctAnswerIndex;
      if (isCorrect) {
        _currentScore++;
      }
      emit(currentState.copyWith(
        selectedAnswerIndex: index,
        isCorrect: isCorrect,
        score: _currentScore,
      ));
    }
  }

  void nextQuestion() {
    if (state is QuizLoaded) {
      _currentQuestionIndex++;
      loadQuestion(_selectedFilter);
    }
  }

  void resetQuiz() {
    initQuiz();
  }
}
