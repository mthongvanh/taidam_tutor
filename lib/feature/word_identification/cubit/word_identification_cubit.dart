import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/core/services/word_identification_service.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_state.dart';

class WordIdentificationCubit extends Cubit<WordIdentificationState> {
  WordIdentificationCubit({
    WordIdentificationService? service,
    List<Character>? characters,
  })  : _service = service ?? dm.get<WordIdentificationService>(),
        _characters = characters,
        super(const WordIdentificationState(isLoading: true)) {
    loadChallenge();
  }

  final WordIdentificationService _service;
  final List<Character>? _characters;

  Future<void> loadChallenge() async {
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        setSelectedOption: true,
        selectedOptionIndex: null,
        setSelectionCorrect: true,
        isSelectionCorrect: null,
      ),
    );

    try {
      late final challenge;
      if (_characters != null) {
        challenge = await _service.buildChallengeFromCharacters(
          characters: _characters.map((c) => c.character).toList(),
          optionCount: _optionCountForMode(state.mode),
        );
      } else {
        challenge = await _service.buildChallenge(
          optionCount: _optionCountForMode(state.mode),
        );
      }

      emit(
        state.copyWith(
          isLoading: false,
          challenge: challenge,
          currentQuestionIndex: 0,
          totalAnswered: 0,
          totalCorrect: 0,
          clearErrorMessage: true,
          setSelectedOption: true,
          selectedOptionIndex: null,
          setSelectionCorrect: true,
          isSelectionCorrect: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _errorMessageFor(error),
          clearErrorMessage: false,
        ),
      );
    }
  }

  void changeMode(WordIdentificationMode mode) {
    if (state.mode == mode) return;

    emit(
      state.copyWith(
        mode: mode,
      ),
    );
    loadChallenge();
  }

  void selectOption(int optionIndex) {
    if (state.isLoading) return;
    if (state.selectedOptionIndex != null) return;

    final question = state.currentQuestion;
    if (question == null) return;
    if (optionIndex < 0 || optionIndex >= question.soundOptions.length) {
      return;
    }

    final isCorrect = question.correctOptionIndex == optionIndex;

    emit(
      state.copyWith(
        setSelectedOption: true,
        selectedOptionIndex: optionIndex,
        setSelectionCorrect: true,
        isSelectionCorrect: isCorrect,
        totalAnswered: state.totalAnswered + 1,
        totalCorrect: isCorrect ? state.totalCorrect + 1 : state.totalCorrect,
      ),
    );
  }

  void nextWord() {
    if (state.isLoading) return;
    final challenge = state.challenge;
    if (challenge == null) {
      loadChallenge();
      return;
    }

    final nextIndex = state.currentQuestionIndex + 1;
    if (nextIndex < challenge.questions.length) {
      emit(
        state.copyWith(
          currentQuestionIndex: nextIndex,
          setSelectedOption: true,
          selectedOptionIndex: null,
          setSelectionCorrect: true,
          isSelectionCorrect: null,
        ),
      );
    } else {
      loadChallenge();
    }
  }

  int _optionCountForMode(WordIdentificationMode mode) {
    switch (mode) {
      case WordIdentificationMode.beginner:
        return 3;
      case WordIdentificationMode.intermediate:
        return 4;
      case WordIdentificationMode.advanced:
        return 5;
    }
  }

  String _errorMessageFor(Object error) {
    return 'Unable to build a challenge right now. ${error.toString()}';
  }
}
