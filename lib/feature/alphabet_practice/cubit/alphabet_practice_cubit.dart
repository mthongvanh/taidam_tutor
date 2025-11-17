import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/alphabet_practice_state.dart';

class AlphabetPracticeCubit extends Cubit<AlphabetPracticeState> {
  final CharacterRepository _characterRepository;
  final AlphabetPracticeRepository _practiceRepository;

  AlphabetPracticeCubit({
    required CharacterRepository characterRepository,
    required AlphabetPracticeRepository practiceRepository,
  })  : _characterRepository = characterRepository,
        _practiceRepository = practiceRepository,
        super(const AlphabetPracticeInitial());

  /// Initialize the alphabet practice feature
  Future<void> init() async {
    emit(const AlphabetPracticeLoading());

    try {
      // Initialize repositories
      await _practiceRepository.init();

      // Load all characters
      final characters = await _characterRepository.getCharacters();

      // Group characters by class
      final characterGroups = CharacterGroupingService.groupByClass(characters);

      // Load mastery data
      var masteryData = await _practiceRepository.getAllMasteryData();

      // Initialize mastery data for characters that don't have it yet
      final now = DateTime.now();
      for (final character in characters) {
        if (!masteryData.containsKey(character.characterId)) {
          masteryData[character.characterId] = CharacterMastery(
            characterId: character.characterId,
            lastPracticed: now,
          );
        }
      }

      // Get overall stats
      final stats = await _practiceRepository.getOverallStats();

      emit(AlphabetPracticeLoaded(
        characterGroups: characterGroups,
        masteryData: masteryData,
        stats: stats,
      ));
    } catch (e) {
      emit(AlphabetPracticeError('Failed to load data: $e'));
    }
  }

  /// Record a practice attempt for a character
  Future<void> recordAttempt({
    required int characterId,
    required bool correct,
  }) async {
    final currentState = state;
    if (currentState is! AlphabetPracticeLoaded) return;

    try {
      // Get existing mastery or create new one
      var mastery = currentState.masteryData[characterId] ??
          CharacterMastery(
            characterId: characterId,
            lastPracticed: DateTime.now(),
          );

      // Record the attempt
      mastery = mastery.recordAttempt(correct: correct);

      // Save to repository
      await _practiceRepository.saveMasteryData(mastery);

      // Update state
      final updatedMasteryData = Map<int, CharacterMastery>.from(
        currentState.masteryData,
      );
      updatedMasteryData[characterId] = mastery;

      // Refresh stats
      final stats = await _practiceRepository.getOverallStats();

      emit(AlphabetPracticeLoaded(
        characterGroups: currentState.characterGroups,
        masteryData: updatedMasteryData,
        stats: stats,
      ));
    } catch (e) {
      // Don't emit error, just log it
      debugPrint('Error recording attempt: $e');
    }
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    emit(const AlphabetPracticeLoading());

    try {
      await _practiceRepository.clearAllData();
      await init();
    } catch (e) {
      emit(AlphabetPracticeError('Failed to reset progress: $e'));
    }
  }

  /// Refresh the data
  Future<void> refresh() async {
    await init();
  }
}
