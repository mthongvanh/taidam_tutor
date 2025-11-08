import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/reading_lessons.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_cubit.dart';
import 'package:taidam_tutor/feature/reading_lesson/cubit/reading_lesson_state.dart';
import 'package:taidam_tutor/feature/reading_lesson/models/reading_lesson_models.dart';
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
    final lesson = ReadingLesson.fromJson(lessonData);

    return BlocProvider(
      create: (context) => ReadingLessonCubit()..startLesson(lesson),
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title),
          actions: [
            BlocBuilder<ReadingLessonCubit, ReadingLessonState>(
              builder: (context, state) {
                if (state is ReadingLessonActive) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ReadingLessonCubit>().startLesson(lesson);
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
      LessonStage.goals => GoalsView(state: state),
      LessonStage.combinations => CombinationsView(state: state),
      LessonStage.examples => ExamplesView(state: state),
      LessonStage.practice => PracticeView(state: state),
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
