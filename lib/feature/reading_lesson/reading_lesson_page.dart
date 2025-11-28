import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/reading_lessons/reading_lessons_repository.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/lesson_type.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/combinations_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/completion_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/examples_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/goals_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/practice_view.dart';
import 'package:taidam_tutor/feature/word_identification/word_identification_page.dart';

class ReadingLessonPage extends StatefulWidget {
  final int lessonNumber;

  const ReadingLessonPage({
    super.key,
    required this.lessonNumber,
  });

  @override
  State<ReadingLessonPage> createState() => _ReadingLessonPageState();
}

class _ReadingLessonPageState extends State<ReadingLessonPage> {
  late final ReadingLessonsRepository _readingLessonsRepository;
  late final CharacterRepository _characterRepository;
  late final Future<Map<String, dynamic>?> _lessonFuture;
  Future<Map<int, Character>>? _characterMapFuture;
  Future<ReadingLesson>? _wordIdentificationLessonFuture;

  @override
  void initState() {
    super.initState();
    _readingLessonsRepository = dm.get<ReadingLessonsRepository>();
    _characterRepository = dm.get<CharacterRepository>();
    _lessonFuture =
        _readingLessonsRepository.getLessonByNumber(widget.lessonNumber);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _lessonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold('Reading Lesson');
        }

        if (snapshot.hasError) {
          return _buildErrorScaffold(
            'Reading Lesson',
            'Error loading lesson: ${snapshot.error}',
          );
        }

        final lessonData = snapshot.data;

        if (lessonData == null) {
          return _buildErrorScaffold(
            'Reading Lesson',
            'Lesson ${widget.lessonNumber} not found.',
          );
        }

        final lessonMeta = lessonData['lesson'] as Map<String, dynamic>? ??
            const <String, dynamic>{};
        final fallbackTitle =
            lessonMeta['title'] as String? ?? 'Reading Lesson';
        final lessonType =
            LessonType.fromKey(lessonMeta['lessonType'] as String?);

        if (lessonType == LessonType.wordIdentification) {
          _wordIdentificationLessonFuture ??=
              _loadWordIdentificationLesson(lessonData);

          return FutureBuilder<ReadingLesson>(
            future: _wordIdentificationLessonFuture,
            builder: (context, lessonSnapshot) {
              if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScaffold(fallbackTitle);
              }

              if (lessonSnapshot.hasError) {
                return _buildErrorScaffold(
                  fallbackTitle,
                  'Error loading lesson: ${lessonSnapshot.error}',
                );
              }

              final readingLesson = lessonSnapshot.data;
              if (readingLesson == null) {
                return _buildErrorScaffold(
                  fallbackTitle,
                  'Lesson ${widget.lessonNumber} not found.',
                );
              }

              final glyphs = _exampleGlyphsForLesson(readingLesson);
              final presetGlyphs = glyphs.isEmpty ? null : glyphs;

              final title = readingLesson.title.isNotEmpty
                  ? readingLesson.title
                  : fallbackTitle;

              return WordIdentificationPage(
                title: title,
                presetGlyphs: presetGlyphs,
              );
            },
          );
        }

        return BlocProvider(
          create: (context) => ReadingLessonCubit()..startLesson(lessonData),
          child: Scaffold(
            appBar: AppBar(
              title: BlocBuilder<ReadingLessonCubit, ReadingLessonState>(
                builder: (context, state) {
                  final title = switch (state) {
                    ReadingLessonActive() => state.lesson.title,
                    ReadingLessonCompleted() => state.lesson.title,
                    _ => fallbackTitle,
                  };
                  return Text(title);
                },
              ),
              actions: [
                BlocBuilder<ReadingLessonCubit, ReadingLessonState>(
                  builder: (context, state) {
                    if (state is ReadingLessonActive) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.flag_outlined),
                            tooltip: 'Choose goal to start from',
                            onPressed: () =>
                                showGoalSelectionSheet(context, state),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              context
                                  .read<ReadingLessonCubit>()
                                  .startLesson(lessonData);
                            },
                            tooltip: 'Restart Lesson',
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: BlocBuilder<ReadingLessonCubit, ReadingLessonState>(
              builder: (context, state) => switch (state) {
                ReadingLessonInitial() ||
                ReadingLessonLoading() =>
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ReadingLessonActive() => _buildActiveLesson(context, state),
                ReadingLessonCompleted() => CompletionView(state: state),
                ReadingLessonError() => Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveLesson(BuildContext context, ReadingLessonActive state) {
    return switch (state.stage) {
      LessonStage.goalOverview => GoalsView(state: state),
      LessonStage.goalCombinations => CombinationsView(state: state),
      LessonStage.goalExamples => ExamplesView(state: state),
      LessonStage.goalPractice => _buildPracticeView(context, state),
      LessonStage.completed => CompletionView(
          state: ReadingLessonCompleted(
            lesson: state.lesson,
            score: state.score,
            totalQuestions: state.totalPracticeQuestions,
          ),
        ),
    };
  }

  Widget _buildPracticeView(BuildContext context, ReadingLessonActive state) {
    if (state.lesson.lessonType == LessonType.wordIdentification) {
      final glyphs = _exampleGlyphsForLesson(state.lesson);
      return WordIdentificationPage(
        title: state.lesson.title,
        presetGlyphs: glyphs.isEmpty ? null : glyphs,
      );
    }
    return PracticeView(state: state);
  }

  Scaffold _buildLoadingScaffold(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildErrorScaffold(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<ReadingLesson> _loadWordIdentificationLesson(
    Map<String, dynamic> lessonData,
  ) async {
    final characterMap = await _loadCharacterMap();
    return ReadingLesson.fromJson(lessonData, characterMap);
  }

  Future<Map<int, Character>> _loadCharacterMap() {
    _characterMapFuture ??=
        _characterRepository.getCharacters().then((characters) {
      return {
        for (final character in characters) character.characterId: character,
      };
    });
    return _characterMapFuture!;
  }

  List<String> _exampleGlyphsForLesson(ReadingLesson lesson) {
    final examples = lesson.examples;
    if (examples == null || examples.isEmpty) {
      return const [];
    }

    final glyphs = <String>[];
    for (final example in examples) {
      final candidate =
          (example.word ?? example.characters.combinedGlyph).trim();
      if (candidate.isEmpty) continue;
      if (!glyphs.contains(candidate)) {
        glyphs.add(candidate);
      }
    }
    return glyphs;
  }
}
