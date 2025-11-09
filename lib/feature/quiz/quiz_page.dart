import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/filter/filter_type.dart';
import 'package:taidam_tutor/feature/quiz/core/data/models/quiz_question.dart';
import 'package:taidam_tutor/feature/quiz/cubit/quiz_cubit.dart';
import 'package:taidam_tutor/feature/quiz/cubit/quiz_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

class QuizPage extends StatelessWidget {
  final AudioPlayer player = AudioPlayer();

  QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            actions: [
              BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  if (state is QuizLoaded) {
                    return IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => context.read<QuizCubit>().resetQuiz(),
                      tooltip: 'Restart Quiz',
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Select Filter',
                onSelected: context.read<QuizCubit>().updateFilter,
                itemBuilder: (BuildContext context) {
                  return context
                      .read<QuizCubit>()
                      .quizFilters
                      .map((FilterType filter) {
                    return PopupMenuItem<String>(
                      value: filter.name,
                      child: Text(filter.name),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: BlocConsumer<QuizCubit, QuizState>(
            listener: (context, state) {
              if (state is QuizLoaded && state.selectedAnswerIndex != null) {
                _showResult(context, isCorrect: state.isCorrect!);
              }
            },
            builder: (context, state) => switch (state) {
              QuizInitial() || QuizLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              QuizLoaded() => _QuizLoaded(
                  question: state.currentQuestion,
                  progress: state.progress,
                  player: player,
                  score: state.score,
                  selectedAnswerIndex: state.selectedAnswerIndex,
                  isCorrect: state.isCorrect,
                ),
              QuizFinished() => _QuizFinished(
                  state.score.toString(),
                  state.image,
                ),
              QuizError() => TaiError(
                  // state.message,
                  onRetry: () => context.read<QuizCubit>().resetQuiz(),
                ),
              _ => TaiError(
                  // 'Unknown error occurred',
                  onRetry: () => context.read<QuizCubit>().resetQuiz(),
                ),
            },
          ),
        );
      }),
    );
  }

  void _showResult(BuildContext context, {required bool isCorrect}) {
    if (isCorrect) {
      _showSnackBar(
        context,
        'Correct!',
        'assets/images/png/animals.png',
        Colors.green.shade900.withAlpha(200),
      );
    } else {
      _showSnackBar(
        context,
        'Incorrect',
        'assets/images/png/sad-face.png',
        Colors.red.shade900.withAlpha(200),
      );
    }
  }

  void _showSnackBar(
    BuildContext context,
    String text,
    String? image,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    // fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            if (image?.isNotEmpty == true)
              TaiCard.margin(
                child: Image.asset(
                  image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _QuizLoaded extends StatelessWidget {
  final QuizQuestion question;
  final double progress;
  final int score;
  final int? selectedAnswerIndex;
  final bool? isCorrect;

  final AudioPlayer player;

  const _QuizLoaded({
    required this.question,
    required this.player,
    this.progress = 0,
    this.score = 0,
    this.selectedAnswerIndex,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          // backgroundColor: Colors.grey.shade300,
          // color: Colors.blue,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 16.0,
              right: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Score: $score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ..._buildQuestionContent(context),
                const SizedBox(height: 16),
                ...question.options.asMap().entries.map((entry) {
                  return _buildAnswerOption(entry, context);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuestionContent(BuildContext context) {
    List<Widget> content = [];

    if (question.textQuestion != null) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            question.textQuestion!,
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (question.imagePath != null) {
      content.add(
        Image.asset(
          question.imagePath!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (question.audioPath != null) {
      content.add(
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () => player.play(AssetSource(question.audioPath!)),
        ),
      );
    }

    if (question.prompt != null) {
      content.add(
        Text(
          question.prompt!,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return content;
  }

  Widget _buildAnswerOption(
    MapEntry<int, String> entry,
    BuildContext context,
  ) {
    int idx = entry.key;
    String optionText = entry.value;
    bool isSelected = selectedAnswerIndex == idx;
    Color? buttonColor;

    if (selectedAnswerIndex != null) {
      if (isSelected) {
        buttonColor = isCorrect! ? Colors.green.shade300 : Colors.red.shade300;
      } else if (idx == question.correctAnswerIndex && !isCorrect!) {
        // Optionally highlight correct answer if user was wrong and an answer has been selected
        // buttonColor = Colors.green.shade200;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onPressed: selectedAnswerIndex == null
            ? () => context.read<QuizCubit>().selectAnswer(idx)
            : null, // Disable after an answer is selected
        child: Text(optionText),
      ),
    );
  }
}

class _QuizFinished extends StatelessWidget {
  final String score;
  final String? image;
  const _QuizFinished(this.score, this.image);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Finished!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Your score: $score',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TaiCard.margin(
            child: Image.asset(
              image ?? 'assets/images/png/animals.png',
              // width: 200,
              // height: 200,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<QuizCubit>().resetQuiz(),
            child: const Text('Try another quiz'),
          ),
        ],
      ),
    );
  }
}
