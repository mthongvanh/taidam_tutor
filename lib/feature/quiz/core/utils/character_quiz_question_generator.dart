import 'dart:math';

import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/data/filter/filter_type.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/quiz/core/data/models/quiz_question.dart';

class CharacterQuizQuestionGenerator {
  final DependencyManager dm = DependencyManager();

  Future<List<QuizQuestion>> generateQuestions({
    FilterType filter = FilterType.none,
    int numberOfOptions = 4,
  }) async {
    final characters = dm.get<CharacterRepository>();
    final allCharacters = await characters.getCharacters();
    CharacterClass? filterClass;
    switch (filter) {
      case FilterType.vowel:
        filterClass = CharacterClass.vowel;
        break;
      case FilterType.consonant:
        filterClass = CharacterClass.consonant;
        break;
      default:
        filterClass = null;
    }

    if (filterClass != null) {
      allCharacters.removeWhere(
        (character) => character.characterClass != filterClass,
      );
    }

    final questions = <QuizQuestion>[];
    allCharacters.shuffle();
    for (var character in allCharacters.take(10).toList()) {
      final question = generateQuestionFromCharacter(
        character,
        allCharacters,
        numberOfOptions: 4,
      );
      questions.add(question);
    }
    return questions;
  }

  /// Generates a multiple-choice quiz question from a [CharacterModel].
  ///
  /// The question asks to identify the sound of the given character.
  /// [correctCharacter] is the character for which the question is generated.
  /// [allCharacters] is a list of all available characters to pick distractors from.
  /// [numberOfOptions] is the total number of choices for the multiple-choice question (including the correct one).
  QuizQuestion generateQuestionFromCharacter(
    Character correctCharacter,
    List<Character> allCharacters, {
    int numberOfOptions = 4,
  }) {
    if (numberOfOptions < 2) {
      throw ArgumentError('Number of options must be at least 2.');
    }
    if (allCharacters.length < numberOfOptions) {
      throw ArgumentError(
          'Not enough characters in allCharacters to generate the specified number of options.');
    }

    final String prompt = 'What is the sound of this character?';
    final String questionText = correctCharacter.character;
    final List<String> options = [];
    final Random random = Random();

    // Add the correct answer
    options.add(correctCharacter.romanization ?? '');

    // Add distractors
    final List<Character> distractors = List<Character>.from(allCharacters)
      ..removeWhere(
        (char) => char.romanization == correctCharacter.romanization,
      ); // Ensure no duplicates of correct answer model

    distractors.shuffle(random);

    for (int i = 0;
        options.length < numberOfOptions && i < distractors.length;
        i++) {
      if (!options.contains(distractors[i].romanization)) {
        // Ensure unique sound options
        options.add(distractors[i].romanization ?? '');
      }
    }

    // If not enough unique distractors were found from different characters,
    // this part might need more sophisticated logic, e.g. error handling or alternative distractor sources.
    // For now, we assume enough unique sounds are available.

    options.shuffle(random); // Shuffle all options

    final int correctAnswerIndex =
        options.indexOf(correctCharacter.romanization ?? '');

    return QuizQuestion(
      id: 'char_${correctCharacter.characterId}_${DateTime.now().millisecondsSinceEpoch}',
      prompt: prompt,
      textQuestion: questionText,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      // You might want to add the character itself or an image path to the question
      // e.g., characterDisplay: correctCharacter.character,
    );
  }
}
