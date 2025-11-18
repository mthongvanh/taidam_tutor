import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/reading_lessons.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/combinations_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/completion_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/examples_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/goals_view.dart';
import 'package:taidam_tutor/feature/reading_lesson/widgets/practice_view.dart';

class ReadingLessonPage extends StatelessWidget {
  final int lessonNumber;

  const ReadingLessonPage({
    super.key,
    required this.lessonNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Get lesson data
    final lessonData =
        lessonNumber == 1 ? ReadingLessons.lesson1 : ReadingLessons.lesson2;
    final lessonMeta = lessonData['lesson'] as Map<String, dynamic>;
    final fallbackTitle = lessonMeta['title'] as String? ?? 'Reading Lesson';

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
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context
                          .read<ReadingLessonCubit>()
                          .startLesson(lessonData);
                    },
                    tooltip: 'Restart Lesson',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<ReadingLessonCubit, ReadingLessonState>(
          builder: (context, state) => switch (state) {
            ReadingLessonInitial() || ReadingLessonLoading() => const Center(
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
  }

  Widget _buildActiveLesson(BuildContext context, ReadingLessonActive state) {
    return switch (state.stage) {
      LessonStage.goalOverview => GoalsView(state: state),
      LessonStage.goalCombinations => CombinationsView(state: state),
      LessonStage.goalExamples => ExamplesView(state: state),
      LessonStage.goalPractice => PracticeView(state: state),
      LessonStage.completed => CompletionView(
          state: ReadingLessonCompleted(
            lesson: state.lesson,
            score: state.score,
            totalQuestions: state.totalPracticeQuestions,
          ),
        ),
    };
  }
}
