import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

/// Service for grouping and filtering characters for learning purposes
class CharacterGroupingService {
  /// Group characters by their character class
  static Map<CharacterClass, List<Character>> groupByClass(
      List<Character> characters) {
    final Map<CharacterClass, List<Character>> groups = {
      for (final cls in CharacterClassX.recommendedLearningOrder) cls: [],
      CharacterClass.vowelFinal: [],
      CharacterClass.unknown: [],
    };

    for (final character in characters) {
      final className = character.characterClass;
      groups.putIfAbsent(className, () => []);
      groups[className]!.add(character);
    }

    return groups;
  }

  /// Get all consonants, optionally filtered by high/low class
  static List<Character> getConsonants(
    List<Character> characters, {
    String? highLow,
  }) {
    return characters.where((char) {
      if (char.characterClass != CharacterClass.consonant) return false;
      if (highLow != null && char.highLow != highLow) return false;
      return true;
    }).toList();
  }

  /// Get all vowels, optionally filtered by pre/post position
  static List<Character> getVowels(
    List<Character> characters, {
    String? prePost,
  }) {
    return characters.where((char) {
      if (char.characterClass != CharacterClass.vowel) return false;
      if (prePost != null && char.prePost != prePost) return false;
      return true;
    }).toList();
  }

  /// Get vowel combinations
  static List<Character> getVowelCombos(List<Character> characters) {
  return characters
    .where((char) => char.characterClass == CharacterClass.vowelCombo)
    .toList();
  }

  /// Get special characters
  static List<Character> getSpecialCharacters(List<Character> characters) {
  return characters
    .where((char) => char.characterClass == CharacterClass.special)
    .toList();
  }

  /// Get characters by specific class
  static List<Character> getByClass(
    List<Character> characters,
    CharacterClass characterClass,
  ) {
    return characters
        .where((char) => char.characterClass == characterClass)
        .toList();
  }

  /// Get a subset of characters for a learning session
  /// Returns a manageable number of characters to practice
  static List<Character> getLearningBatch(
    List<Character> characters, {
    int batchSize = 5,
    int offset = 0,
  }) {
    final startIndex = offset;
    final endIndex = (offset + batchSize).clamp(0, characters.length);

    if (startIndex >= characters.length) return [];

    return characters.sublist(startIndex, endIndex);
  }

  /// Get similar-looking characters for distractor options in quizzes
  /// This is a simple implementation that could be enhanced with visual similarity
  static List<Character> getSimilarCharacters(
    Character target,
    List<Character> allCharacters, {
    int count = 3,
  }) {
    // Filter by same character class
    final sameClass = allCharacters
        .where((char) =>
      char.characterClass == target.characterClass &&
            char.characterId != target.characterId)
        .toList();

    // If we have enough from same class, use those
    if (sameClass.length >= count) {
      sameClass.shuffle();
      return sameClass.take(count).toList();
    }

    // Otherwise, include characters from other classes
    final others = allCharacters
        .where((char) => char.characterId != target.characterId)
        .toList();

    others.shuffle();
    return others.take(count).toList();
  }

  /// Get recommended learning order for character classes
  static List<CharacterClass> getRecommendedLearningOrder() {
    return CharacterClassX.recommendedLearningOrder;
  }

  /// Get a descriptive title for a character class
  static String getClassTitle(CharacterClass characterClass) {
    return characterClass.title;
  }

  /// Get a description for a character class
  static String getClassDescription(CharacterClass characterClass) {
    return characterClass.description;
  }
}
