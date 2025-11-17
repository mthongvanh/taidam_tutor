import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';

sealed class AlphabetPracticeState extends Equatable {
  const AlphabetPracticeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the feature is first loaded
class AlphabetPracticeInitial extends AlphabetPracticeState {
  const AlphabetPracticeInitial();
}

/// Loading state
class AlphabetPracticeLoading extends AlphabetPracticeState {
  const AlphabetPracticeLoading();
}

/// State when data is successfully loaded
class AlphabetPracticeLoaded extends AlphabetPracticeState {
  final Map<CharacterClass, List<Character>> characterGroups;
  final Map<int, CharacterMastery> masteryData;
  final Map<String, dynamic> stats;

  const AlphabetPracticeLoaded({
    required this.characterGroups,
    required this.masteryData,
    required this.stats,
  });

  /// Get mastery data for a specific character
  CharacterMastery? getMasteryForCharacter(int characterId) {
    return masteryData[characterId];
  }

  /// Get overall progress percentage (0.0 to 1.0)
  double get overallProgress {
    if (masteryData.isEmpty) return 0.0;
    final masteredCount = masteryData.values.where((m) => m.isMastered).length;
    return masteredCount / masteryData.length;
  }

  /// Get progress for a specific character class
  double getClassProgress(CharacterClass characterClass) {
    final classCharacters = characterGroups[characterClass] ?? [];
    if (classCharacters.isEmpty) return 0.0;

    final masteredInClass = classCharacters
        .where((char) => masteryData[char.characterId]?.isMastered ?? false)
        .length;

    return masteredInClass / classCharacters.length;
  }

  @override
  List<Object?> get props => [characterGroups, masteryData, stats];
}

/// Error state
class AlphabetPracticeError extends AlphabetPracticeState {
  final String message;

  const AlphabetPracticeError(this.message);

  @override
  List<Object?> get props => [message];
}
