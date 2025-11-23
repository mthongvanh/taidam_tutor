import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';

/// Holds the canonical character IDs used in a lesson section alongside the
/// resolved [Character] models for rendering.
class LessonCharacterSet extends Equatable {
  final List<int> characterIds;
  final List<Character> characters;

  const LessonCharacterSet({
    required this.characterIds,
    required this.characters,
  });

  factory LessonCharacterSet.fromJson(
    List<dynamic> ids,
    Map<int, Character> characterMap,
  ) {
    final parsedIds = ids.map((id) => (id as num).toInt()).toList();
    final resolvedCharacters =
        parsedIds.map((id) => characterMap[id]).whereType<Character>().toList();

    return LessonCharacterSet(
      characterIds: parsedIds,
      characters: resolvedCharacters,
    );
  }

  List<String> get glyphs => characters.map((c) => c.character).toList();

  String get combinedGlyph {
    // for single characters, just return the glyph
    if (characters.length <= 1) {
      return glyphs.join();
    }

    // for multiple characters, handle vowel combinations specially
    String combined = '';
    for (final character in characters.indexed) {
      final component = character.$2;
      if (component.characterClass == CharacterClass.consonant) {
        // for consonants, we need to check the next character to see if it's a vowel
        // that modifies the consonant glyph
        final nextIndex = character.$1 + 1;
        if (nextIndex < characters.length) {
          // there is a next character. Check if it's a vowel that modifies this consonant
          // e.g., a consonant followed by a vowel with pre/post components
          // The logic is:
          // - If the vowel has a pre-component, prepend it to the consonant glyph
          // - If the vowel has a post-component, append it to the consonant glyph
          final nextComponent = characters[nextIndex];
          if (nextComponent.characterClass == CharacterClass.vowel) {
            if (nextComponent.preComponent?.isNotEmpty ?? false) {
              combined += nextComponent.preComponent!;
            }
            if (nextComponent.postComponent?.isNotEmpty ?? false) {
              combined +=
                  "${component.character}${nextComponent.postComponent ?? ''}";
            } else {
              combined += component.character;
            }
          }
        }
      } else {
        // Standalone vowel or vowel not following a consonant: include its glyph
        combined += component.character;
      }
    }
    return combined;
  }

  String get primaryRomanization => characters
      .map(_primaryRomanizationFor)
      .where((value) => value.isNotEmpty)
      .join();

  String get primaryIpaDescription {
    for (final character in characters) {
      final description = character.ipaDescription;
      if (description != null && description.trim().isNotEmpty) {
        return description.trim();
      }
    }
    return '';
  }

  bool get hasMissingCharacters => characters.length != characterIds.length;

  @override
  List<Object?> get props => [characterIds, characters];
}

/// Represents a learning goal for a lesson
class LessonGoal extends Equatable {
  final LessonCharacterSet characters;
  final String? description;

  const LessonGoal({
    required this.characters,
    required this.description,
  });

  factory LessonGoal.fromJson(
    Map<String, dynamic> json,
    Map<int, Character> characterMap,
  ) {
    return LessonGoal(
      characters: LessonCharacterSet.fromJson(
        _characterIdsFromJson(json),
        characterMap,
      ),
      description: json['description'] as String?,
    );
  }

  String get displayText => characters.combinedGlyph;

  String get romanization => characters.primaryRomanization;

  String get ipaDescription => characters.primaryIpaDescription;

  @override
  List<Object?> get props => [characters, description];
}

/// Represents a character combination in a lesson
class Combination extends Equatable {
  final LessonCharacterSet characters;
  final String description;

  const Combination({
    required this.characters,
    required this.description,
  });

  factory Combination.fromJson(
    Map<String, dynamic> json,
    Map<int, Character> characterMap,
  ) {
    return Combination(
      characters: LessonCharacterSet.fromJson(
        _characterIdsFromJson(json),
        characterMap,
      ),
      description: json['description'] as String,
    );
  }

  String get result => characters.combinedGlyph;

  List<String> get componentGlyphs => characters.glyphs;

  List<String> get componentRomanizations =>
      characters.characters.map(_primaryRomanizationFor).toList();

  String get romanization => characters.primaryRomanization;

  String get practiceDescription {
    // produces: Sounds like 'ng-ooah' in 'sung-ooah' (ꪉ + ꪺ) [ngua]
    // final glyphParts = componentGlyphs.join(' + ');
    // final pronunciation = romanization;
    // final pronunciationSuffix =
    //     pronunciation.isNotEmpty ? ' [$pronunciation]' : '';
    // return '$description ($glyphParts)$pronunciationSuffix';
    return romanization;
  }

  @override
  List<Object?> get props => [characters, description];
}

/// Represents an example word in a lesson
class Example extends Equatable {
  final LessonCharacterSet characters;
  final String? word;
  final String? romanization;

  const Example({
    required this.characters,
    this.word,
    this.romanization,
  });

  factory Example.fromJson(
    Map<String, dynamic> json,
    Map<int, Character> characterMap,
  ) {
    return Example(
      characters: LessonCharacterSet.fromJson(
        _characterIdsFromJson(json),
        characterMap,
      ),
      word: json['word'] as String?,
      romanization: json['romanization'] as String?,
    );
  }

  String get displayWord => word ?? characters.combinedGlyph;

  String get displayRomanization {
    if (romanization != null && romanization!.isNotEmpty) {
      return romanization!;
    }
    final fallback = characters.primaryRomanization;
    return fallback.isNotEmpty ? fallback : 'Sound it out aloud!';
  }

  @override
  List<Object?> get props => [characters, word, romanization];
}

/// Represents a complete reading lesson
class ReadingLesson extends Equatable {
  final int number;
  final String title;
  final String? titleRomanization;
  final String description;
  final String shortDescription;
  final List<LessonGoal> goals;
  final List<Combination> combinations;
  final List<Example>? examples;

  const ReadingLesson({
    required this.number,
    required this.title,
    this.titleRomanization,
    required this.description,
    required this.shortDescription,
    required this.goals,
    required this.combinations,
    this.examples,
  });

  factory ReadingLesson.fromJson(
    Map<String, dynamic> json,
    Map<int, Character> characterMap,
  ) {
    final lessonData = json['lesson'] as Map<String, dynamic>;
    return ReadingLesson(
      number: lessonData['number'] as int,
      title: lessonData['title'] as String,
      titleRomanization: lessonData['titleRomanization'] as String?,
      description: lessonData['description'] as String,
      shortDescription: (lessonData['shortDescription'] as String?) ??
          (lessonData['description'] as String),
      goals: (lessonData['goals'] as List)
          .map(
            (g) => LessonGoal.fromJson(
              g as Map<String, dynamic>,
              characterMap,
            ),
          )
          .toList(),
      combinations: (lessonData['combinations'] as List)
          .map(
            (c) => Combination.fromJson(
              c as Map<String, dynamic>,
              characterMap,
            ),
          )
          .toList(),
      examples: lessonData['examples'] != null
          ? (lessonData['examples'] as List)
              .map(
                (e) => Example.fromJson(
                  e as Map<String, dynamic>,
                  characterMap,
                ),
              )
              .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        number,
        title,
        titleRomanization,
        description,
        shortDescription,
        goals,
        combinations,
        examples,
      ];
}

String _primaryRomanizationFor(Character character) {
  final raw = character.romanization;
  if (raw == null || raw.isEmpty) return '';
  // Romanization strings often include multiple comma-separated options.
  final firstEntry = raw.split(',').first.trim();
  return firstEntry.replaceAll(RegExp(r'\s+'), '');
}

List<dynamic> _characterIdsFromJson(Map<String, dynamic> json) {
  return json['characterIds'] as List<dynamic>? ?? const <dynamic>[];
}
