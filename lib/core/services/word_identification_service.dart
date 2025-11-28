import 'dart:math';

import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/reading_lessons/reading_lessons_repository.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';

/// Builds randomized word-identification challenges by combining reading
/// lesson glyph segments and their associated romanizations and sound
/// descriptions.
///
/// The service lazily loads all reading lessons and characters, caches the
/// derived [_SoundCandidate] entries, and then assembles multi-segment words
/// whose total glyph length falls within a caller-provided range. Each segment
/// is presented with multiple-choice romanizations drawn from a global
/// distractor pool to keep prompts varied between invocations.
class WordIdentificationService {
  WordIdentificationService({
    ReadingLessonsRepository? readingLessonsRepository,
    CharacterRepository? characterRepository,
    Random? random,
  })  : _readingLessonsRepository =
            readingLessonsRepository ?? dm.get<ReadingLessonsRepository>(),
        _characterRepository =
            characterRepository ?? dm.get<CharacterRepository>(),
        _random = random ?? Random();

  final ReadingLessonsRepository _readingLessonsRepository;
  final CharacterRepository _characterRepository;
  final Random _random;

  final List<_SoundCandidate> _candidates = [];
  final Map<String, List<_SoundCandidate>> _candidatesByGlyph = {};
  final List<String> _romanizationPool = [];
  bool _isInitialized = false;

  /// Builds a new challenge ensuring each segment's glyph length stays within
  /// [minGlyphLength] and [maxGlyphLength], and returns multiple-choice options
  /// of size [optionCount] for every segment selected.
  Future<WordIdentificationChallenge> buildChallenge({
    int minGlyphLength = 6,
    int maxGlyphLength = 10,
    int optionCount = 4,
  }) async {
    await _ensureInitialized();

    if (_candidates.length < 2) {
      throw StateError('Not enough data to create a word challenge.');
    }

    _validateOptionCount(optionCount);

    final segments = _pickSegments(
      minGlyphLength: minGlyphLength,
      maxGlyphLength: maxGlyphLength,
    );

    return _buildChallengeFromSegments(
      segments: segments,
      optionCount: optionCount,
    );
  }

  /// Builds a challenge from the provided ordered list of [characters] (glyph
  /// strings such as 'ꪀ'). Each entry must match a known reading lesson
  /// combination; otherwise a [StateError] is thrown. This enables targeted
  /// practice sessions for specific characters.
  Future<WordIdentificationChallenge> buildChallengeFromCharacters({
    required List<String> characters,
    int optionCount = 4,
  }) async {
    await _ensureInitialized();

    _validateOptionCount(optionCount);
    final segments = _segmentsForGlyphs(characters);

    return _buildChallengeFromSegments(
      segments: segments,
      optionCount: optionCount,
    );
  }

  /// Loads and caches lesson combinations exactly once before challenge
  /// construction to avoid repeated JSON parsing and allocations.
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final characters = await _characterRepository.getCharacters();
    final characterMap = {for (final c in characters) c.characterId: c};
    final lessons = await _readingLessonsRepository.getLessons();

    final parsedLessons = lessons
        .map(
          (lesson) => ReadingLesson.fromJson(
            lesson,
            characterMap,
          ),
        )
        .toList();

    for (final lesson in parsedLessons) {
      for (final combination in lesson.combinations) {
        final glyph = combination.result.trim();
        final description = _sanitizeDescription(combination.description);
        final romanization = _sanitizeRomanization(combination.romanization);
        _registerCandidate(
          glyph: glyph,
          romanization: romanization,
          description: description,
        );
      }

      final examples = lesson.examples ?? const <Example>[];
      for (final example in examples) {
        final glyph = (example.word ?? example.characters.combinedGlyph).trim();
        final romanization = _sanitizeRomanization(example.displayRomanization);
        final description = _sanitizeDescription(
          example.characters.primaryIpaDescription,
        );
        _registerCandidate(
          glyph: glyph,
          romanization: romanization,
          description: description.isNotEmpty
              ? description
              : 'Sound this syllable out loud.',
        );
      }
    }

    _isInitialized = true;
  }

  void _registerCandidate({
    required String glyph,
    required String romanization,
    required String description,
  }) {
    final trimmedGlyph = glyph.trim();
    final trimmedRomanization = romanization.trim();
    final trimmedDescription = description.trim();
    if (trimmedGlyph.isEmpty || trimmedRomanization.isEmpty) {
      return;
    }

    final segment = WordSegment(
      glyph: trimmedGlyph,
      romanization: trimmedRomanization,
      soundDescription: trimmedDescription.isNotEmpty
          ? trimmedDescription
          : trimmedRomanization,
    );

    final candidate = _SoundCandidate(
        segment: segment, glyphLength: _glyphLength(trimmedGlyph));
    _candidates.add(candidate);
    _candidatesByGlyph.putIfAbsent(trimmedGlyph, () => []).add(candidate);
    _addToRomanizationPool(trimmedRomanization);
  }

  void _addToRomanizationPool(String romanization) {
    final normalized = romanization.toLowerCase().trim();
    final exists = _romanizationPool.any(
      (value) => value.toLowerCase().trim() == normalized,
    );
    if (!exists) {
      _romanizationPool.add(romanization);
    }
  }

  /// Chooses a list of segments whose combined glyph count falls within the
  /// provided range, retrying up to a capped number of attempts.
  List<WordSegment> _pickSegments({
    required int minGlyphLength,
    required int maxGlyphLength,
  }) {
    const int maxAttempts = 200;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final selection = <_SoundCandidate>[];
      var totalLength = 0;

      while (totalLength < minGlyphLength && selection.length < 6) {
        final candidate = _candidates[_random.nextInt(_candidates.length)];
        selection.add(candidate);
        totalLength += candidate.glyphLength;
      }

      if (selection.length < 2 || totalLength < minGlyphLength) {
        continue;
      }

      while (totalLength > maxGlyphLength && selection.length > 2) {
        final removed = selection.removeLast();
        totalLength -= removed.glyphLength;
      }

      if (totalLength >= minGlyphLength && totalLength <= maxGlyphLength) {
        return selection.map((candidate) => candidate.segment).toList();
      }
    }

    throw StateError('Unable to build a word challenge with current data.');
  }

  /// Converts the supplied glyph strings into their corresponding segments,
  /// preserving input order and throwing if a glyph cannot be resolved.
  List<WordSegment> _segmentsForGlyphs(List<String> characters) {
    final sanitizedGlyphs = characters
        .map((glyph) => glyph.trim())
        .where((glyph) => glyph.isNotEmpty)
        .toList();

    if (sanitizedGlyphs.isEmpty) {
      throw ArgumentError(
          'At least one glyph is required to build a challenge.');
    }

    final segments = <WordSegment>[];

    for (final glyph in sanitizedGlyphs) {
      final matches = _candidatesByGlyph[glyph];
      if (matches == null || matches.isEmpty) {
        throw StateError('No sound data available for glyph "$glyph".');
      }
      final selected = matches[_random.nextInt(matches.length)];
      segments.add(selected.segment);
    }

    return segments;
  }

  WordIdentificationChallenge _buildChallengeFromSegments({
    required List<WordSegment> segments,
    required int optionCount,
  }) {
    if (segments.isEmpty) {
      throw StateError('No segments available to build a word challenge.');
    }

    final questions = segments.map((segment) {
      final options = _buildOptions(
        correct: segment.romanization,
        desiredCount: optionCount,
      );
      final correctIndex = options.indexWhere(
        (option) =>
            option.toLowerCase().trim() ==
            segment.romanization.toLowerCase().trim(),
      );

      return WordQuestion(
        segment: segment,
        soundOptions: options,
        correctOptionIndex: correctIndex >= 0 ? correctIndex : 0,
      );
    }).toList();

    return WordIdentificationChallenge(questions: questions);
  }

  /// Builds a shuffled list of romanizations containing the [correct]
  /// answer plus distractors drawn from the global option pool.
  List<String> _buildOptions({
    required String correct,
    required int desiredCount,
  }) {
    final sanitizedCorrect = correct.trim();
    final options = <String>[sanitizedCorrect];

    final distractors = _romanizationPool
        .where(
          (candidate) =>
              candidate.toLowerCase().trim() != sanitizedCorrect.toLowerCase(),
        )
        .toList();

    distractors.shuffle(_random);

    for (final candidate in distractors) {
      if (options.length >= desiredCount) break;
      options.add(candidate);
    }

    options.shuffle(_random);
    return options;
  }

  /// Counts visible glyph characters, honoring composed Unicode sequences.
  int _glyphLength(String glyph) => glyph.characters.length;

  void _validateOptionCount(int optionCount) {
    if (optionCount < 2) {
      throw ArgumentError.value(
        optionCount,
        'optionCount',
        'must be at least 2',
      );
    }
  }

  /// Normalizes raw descriptions, collapsing null/empty inputs to an empty
  /// string so they can be filtered out cleanly upstream.
  String _sanitizeDescription(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return '';
  }

  String _sanitizeRomanization(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return '';
  }
}

/// Represents a full word challenge composed of multiple segment questions.
class WordIdentificationChallenge extends Equatable {
  final List<WordQuestion> questions;

  const WordIdentificationChallenge({required this.questions});

  /// Concatenated glyph string for the full answer, useful for result screens.
  String get fullGlyph => questions.map((e) => e.segment.glyph).join();

  @override
  List<Object?> get props => [questions];
}

/// A single glyph segment paired with its multiple-choice romanization options.
class WordQuestion extends Equatable {
  final WordSegment segment;
  final List<String> soundOptions;
  final int correctOptionIndex;

  const WordQuestion({
    required this.segment,
    required this.soundOptions,
    required this.correctOptionIndex,
  });

  @override
  List<Object?> get props => [segment, soundOptions, correctOptionIndex];
}

/// Immutable representation of a reading lesson combination result.
class WordSegment extends Equatable {
  final String glyph;
  final String romanization;
  final String soundDescription;

  const WordSegment({
    required this.glyph,
    required this.romanization,
    required this.soundDescription,
  });

  @override
  List<Object?> get props => [glyph, romanization, soundDescription];
}

/// Internal helper storing a segment plus its computed glyph length for quick
/// reuse during challenge assembly.
class _SoundCandidate {
  final WordSegment segment;
  final int glyphLength;

  const _SoundCandidate({
    required this.segment,
    required this.glyphLength,
  });
}
