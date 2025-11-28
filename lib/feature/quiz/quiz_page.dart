import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/core/data/filter/filter_type.dart';
import 'package:taidam_tutor/feature/quiz/core/data/models/quiz_question.dart';
import 'package:taidam_tutor/feature/quiz/cubit/quiz_cubit.dart';
import 'package:taidam_tutor/feature/quiz/cubit/quiz_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

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
                  player: player,
                  score: state.score,
                  selectedAnswerIndex: state.selectedAnswerIndex,
                  isCorrect: state.isCorrect,
                  currentQuestionNumber: state.currentQuestionNumber,
                  totalQuestions: state.totalQuestions,
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
  final int score;
  final int? selectedAnswerIndex;
  final bool? isCorrect;
  final int currentQuestionNumber;
  final int totalQuestions;
  final AudioPlayer player;

  const _QuizLoaded({
    required this.question,
    required this.player,
    required this.currentQuestionNumber,
    required this.totalQuestions,
    this.score = 0,
    this.selectedAnswerIndex,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswered = selectedAnswerIndex != null;

    final promptPieces = <Widget>[];
    if (question.textQuestion != null) {
      promptPieces.add(
        Text(
          question.textQuestion!,
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (question.imagePath != null) {
      promptPieces.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.s),
          child: Image.asset(
            question.imagePath!,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (question.audioPath != null) {
      promptPieces.add(
        ElevatedButton.icon(
          onPressed: () => player.play(AssetSource(question.audioPath!)),
          icon: const Icon(Icons.volume_up),
          label: const Text('Play Audio'),
        ),
      );
    }

    if (promptPieces.isEmpty) {
      promptPieces.add(
        Text(
          question.prompt ?? 'Question',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return QuizPracticeLayout(
      currentQuestion: currentQuestionNumber,
      totalQuestions: totalQuestions,
      scoreLabel: 'Score: $score',
      title: question.prompt ?? 'Quiz Challenge',
      prompt: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.s,
        children: promptPieces,
      ),
      answerDescription: Text(
        'Choose the correct answer:',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
      answerOptions: question.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final optionText = entry.value;
        return AnswerOptionButton(
          label: String.fromCharCode(65 + idx),
          option: optionText,
          isSelected: selectedAnswerIndex == idx,
          isCorrect: idx == question.correctAnswerIndex,
          hasAnswered: hasAnswered,
          onTap: hasAnswered
              ? null
              : () => context.read<QuizCubit>().selectAnswer(idx),
        );
      }).toList(),
      feedback: hasAnswered
          ? _QuizFeedback(
              isCorrect: isCorrect ?? false,
              correctAnswer: question.options[question.correctAnswerIndex],
            )
          : null,
      bottomButton: FilledButton(
        onPressed:
            hasAnswered ? () => context.read<QuizCubit>().nextQuestion() : null,
        child: Text(
          currentQuestionNumber < totalQuestions ? 'Continue' : 'See Results',
        ),
      ),
    );
  }
}

class _QuizFeedback extends StatelessWidget {
  const _QuizFeedback({
    required this.isCorrect,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(Spacing.m),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
          ),
          const SizedBox(width: Spacing.s),
          Expanded(
            child: Text(
              isCorrect
                  ? 'Correct!'
                  : 'Not quite. Correct answer: $correctAnswer',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
