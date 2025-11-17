import 'package:json_annotation/json_annotation.dart';

/// Enumerates the different learning categories a Tai Dam character can belong to.
@JsonEnum(alwaysCreate: false)
enum CharacterClass {
  @JsonValue('consonant')
  consonant,
  @JsonValue('vowel')
  vowel,
  @JsonValue('special')
  special,
  @JsonValue('unknown')
  unknown,
}

extension CharacterClassX on CharacterClass {
  /// Canonical string value used in JSON/storage.
  String get value => const {
        CharacterClass.consonant: 'consonant',
        CharacterClass.vowel: 'vowel',
        CharacterClass.special: 'special',
        CharacterClass.unknown: 'unknown',
      }[this]!;

  /// Display title for UI.
  String get title => const {
        CharacterClass.consonant: 'Consonants',
        CharacterClass.vowel: 'Vowels',
        CharacterClass.special: 'Special Characters',
        CharacterClass.unknown: 'Characters',
      }[this]!;

  /// Description used in onboarding cards.
  String get description => const {
        CharacterClass.consonant: 'Learn consonant sounds and tone classes',
        CharacterClass.vowel:
            'Practice simple vowels and their positions around consonants',
        CharacterClass.special: 'Study tone markers and special purpose glyphs',
        CharacterClass.unknown: 'General character practice',
      }[this]!;

  /// Convenience flag for vowel-focused categories.
  bool get isVowelCategory => {
        CharacterClass.vowel,
      }.contains(this);

  static List<CharacterClass> get recommendedLearningOrder => const [
        CharacterClass.consonant,
        CharacterClass.vowel,
        CharacterClass.special,
      ];

  static CharacterClass fromString(String? raw) {
    if (raw == null) return CharacterClass.unknown;
    return CharacterClass.values.firstWhere(
      (value) => value.value == raw,
      orElse: () => CharacterClass.unknown,
    );
  }
}
