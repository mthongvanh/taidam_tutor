import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/reading_lessons/reading_lessons_repository.dart';
import 'package:taidam_tutor/core/services/word_identification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WordIdentificationService service;

  setUp(() {
    service = WordIdentificationService(
      characterRepository: CharacterRepository(),
      readingLessonsRepository: ReadingLessonsRepository(),
    );
  });

  test('challenge glyph count stays within 6-10 characters', () async {
    final challenge = await service.buildChallenge();

    expect(challenge.questions, isNotEmpty);
    expect(
      challenge.fullGlyph.characters.length,
      inInclusiveRange(6, 10),
    );
  });

  test('challenge options always include the correct romanization', () async {
    const optionCount = 5;
    final challenge = await service.buildChallenge(optionCount: optionCount);

    for (final question in challenge.questions) {
      expect(question.soundOptions.length <= optionCount, isTrue);
      expect(question.soundOptions.length, greaterThanOrEqualTo(2));
      final correctOption = question.soundOptions[question.correctOptionIndex];
      expect(correctOption, equals(question.segment.romanization));
    }
  });

  test('can build challenge from explicit character list', () async {
    final baseline = await service.buildChallenge();
    final glyphs = baseline.questions
        .take(3)
        .map((question) => question.segment.glyph)
        .toList();

    final challenge = await service.buildChallengeFromCharacters(
      characters: glyphs,
      optionCount: 3,
    );

    expect(challenge.questions.length, glyphs.length);
    expect(challenge.fullGlyph, equals(glyphs.join()));
  });

  test('buildChallengeFromCharacters throws when glyph missing', () async {
    expect(
      () => service.buildChallengeFromCharacters(
        characters: const ['nonexistent-glyph'],
      ),
      throwsStateError,
    );
  });
}
