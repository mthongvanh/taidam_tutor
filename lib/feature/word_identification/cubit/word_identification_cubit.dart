import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/core/services/word_identification_service.dart';
import 'package:taidam_tutor/feature/word_identification/cubit/word_identification_state.dart';

class WordIdentificationCubit extends Cubit<WordIdentificationState> {
  WordIdentificationCubit({
    WordIdentificationService? service,
    List<String>? presetGlyphs,
  })  : _service = service ?? dm.get<WordIdentificationService>(),
        _presetGlyphs = presetGlyphs
            ?.map((glyph) => glyph.trim())
            .where((glyph) => glyph.isNotEmpty)
            .toList(growable: false),
        super(const WordIdentificationState(isLoading: true)) {
    loadChallenge();
  }

  final WordIdentificationService _service;
  final List<String>? _presetGlyphs;
  static const int _maxPresetSegmentCount = 5;
  int _presetGlyphCursor = 0;
  List<String>? _activePresetBatch;
  bool _shouldAdvancePresetBatch = true;

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
      late final WordIdentificationChallenge challenge;
      final presetBatch = _obtainPresetBatch();
      if (presetBatch.isNotEmpty) {
        challenge = await _service.buildChallengeFromCharacters(
          characters: presetBatch,
          optionCount: _optionCountForMode(state.mode),
        );
      } else {
        _activePresetBatch = null;
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
      if (_activePresetBatch != null) {
        _shouldAdvancePresetBatch = true;
      }
      loadChallenge();
    }
  }

  List<String> _obtainPresetBatch() {
    final glyphs = _presetGlyphs;
    if (glyphs == null || glyphs.isEmpty) {
      _activePresetBatch = null;
      return const <String>[];
    }

    if (_activePresetBatch != null && !_shouldAdvancePresetBatch) {
      return _activePresetBatch!;
    }

    final batch = _nextPresetGlyphBatch(glyphs);
    _activePresetBatch = batch;
    _shouldAdvancePresetBatch = false;
    return batch;
  }

  List<String> _nextPresetGlyphBatch(List<String> glyphs) {
    if (glyphs.isEmpty) {
      return const <String>[];
    }

    if (_presetGlyphCursor >= glyphs.length) {
      _presetGlyphCursor = 0;
    }

    var end = _presetGlyphCursor + _maxPresetSegmentCount;
    if (end > glyphs.length) {
      end = glyphs.length;
    }

    final batch = glyphs.sublist(_presetGlyphCursor, end);
    _presetGlyphCursor = end;
    return batch;
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
