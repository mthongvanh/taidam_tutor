import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/core/constants/strings.dart';
import 'package:taidam_tutor/feature/flashcard/cubit/flashcard_practice_cubit.dart';
import 'package:taidam_tutor/feature/flashcard/cubit/flashcard_practice_state.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/widgets/answer_option_button.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

class FlashcardPracticePage extends StatelessWidget {
  final AudioPlayer player = AudioPlayer();

  FlashcardPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlashcardPracticeCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flashcard Practice'),
          actions: [
            BlocBuilder<FlashcardPracticeCubit, FlashcardPracticeState>(
              builder: (context, state) {
                if (state is FlashcardPracticeActive) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        context.read<FlashcardPracticeCubit>().resetPractice(),
                    tooltip: 'Restart Practice',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<FlashcardPracticeCubit, FlashcardPracticeState>(
          listener: (context, state) {
            if (state is FlashcardPracticeActive &&
                state.selectedAnswerIndex != null) {
              _playFeedbackSound(state.isCorrect ?? false);
              _showResult(context, isCorrect: state.isCorrect ?? false);
            }
          },
          builder: (context, state) => switch (state) {
            FlashcardPracticeInitial() ||
            FlashcardPracticeLoading() =>
              const Center(
                child: CircularProgressIndicator(),
              ),
            FlashcardPracticeActive() => _PracticeActiveView(
                state: state,
                player: player,
              ),
            FlashcardPracticeCompleted() =>
              _PracticeCompletedView(state: state),
            FlashcardPracticeError() => TaiError(
                onRetry: () =>
                    context.read<FlashcardPracticeCubit>().resetPractice(),
              ),
          },
        ),
      ),
    );
  }

  void _playFeedbackSound(bool isCorrect) {
    // Optional: play different sounds for correct/incorrect
    // For now, just using the existing audio player
  }

  void _showResult(BuildContext context, {required bool isCorrect}) {
    if (isCorrect) {
      _showSnackBar(
        context,
        'Correct! 🎉',
        Colors.green.shade700.withAlpha(200),
      );
    } else {
      _showSnackBar(
        context,
        'Incorrect',
        Colors.red.shade700.withAlpha(200),
      );
    }
  }

  void _showSnackBar(
    BuildContext context,
    String text,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _PracticeActiveView extends StatelessWidget {
  final FlashcardPracticeActive state;
  final AudioPlayer player;

  const _PracticeActiveView({
    required this.state,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final flashcard = state.currentQuestion.flashcard;
    final hasHints = flashcard.hints != null && flashcard.hints!.isNotEmpty;

    final promptContent = Column(
      spacing: Spacing.s,
      children: [
        Text(
          flashcard.question,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: Fonts.characters,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        if (flashcard.audio?.isNotEmpty == true)
          ElevatedButton.icon(
            onPressed: () {
              player.play(AssetSource('audio/${flashcard.audio}.caf'));
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Play Audio'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
      ],
    );

    final hintControls = <Widget>[];
    if (hasHints) {
      hintControls.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.selectedAnswerIndex == null
                    ? () => context.read<FlashcardPracticeCubit>().toggleHint()
                    : null,
                icon: Icon(
                  state.showHint ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(state.showHint ? 'Hide Hint' : 'Show Hint'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );

      if (state.showHint) {
        hintControls.add(
          TaiCard.margin(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...(flashcard.hints!.toList()
                      ..sort((a, b) =>
                          (a.hintOrder ?? 999).compareTo(b.hintOrder ?? 999)))
                    .map(
                  (hint) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${hint.hintDisplayText ?? hint.type.name}: ${hint.content}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return QuizPracticeLayout(
      currentQuestion: state.currentQuestionIndex + 1,
      totalQuestions: state.totalQuestions,
      scoreLabel: 'Score: ${state.score}',
      title: 'Flashcard Practice',
      prompt: promptContent,
      promptExtras: hintControls,
      answerDescription: Text(
        'Select the correct answer:',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      answerOptions: List.generate(
        state.currentQuestion.options.length,
        (index) => AnswerOptionButton(
          label: String.fromCharCode(65 + index),
          option: state.currentQuestion.options[index],
          isSelected: state.selectedAnswerIndex == index,
          isCorrect: index == state.currentQuestion.correctAnswerIndex,
          hasAnswered: state.selectedAnswerIndex != null,
          onTap: state.selectedAnswerIndex == null
              ? () => context.read<FlashcardPracticeCubit>().selectAnswer(index)
              : null,
        ),
      ),
      bottomButton: state.selectedAnswerIndex != null
          ? ElevatedButton(
              onPressed: () =>
                  context.read<FlashcardPracticeCubit>().nextQuestion(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                state.currentQuestionIndex < state.totalQuestions - 1
                    ? 'Next Question'
                    : 'Finish Practice',
                style: const TextStyle(fontSize: 18),
              ),
            )
          : null,
    );
  }
}

class _PracticeCompletedView extends StatelessWidget {
  final FlashcardPracticeCompleted state;

  const _PracticeCompletedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final percentage = state.percentage;
    String emoji;
    String message;

    if (percentage >= 90) {
      emoji = '🏆';
      message = 'Outstanding!';
    } else if (percentage >= 70) {
      emoji = '🎉';
      message = 'Great job!';
    } else if (percentage >= 50) {
      emoji = '👍';
      message = 'Good effort!';
    } else {
      emoji = '💪';
      message = 'Keep practicing!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${state.score} / ${state.totalQuestions}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '(${percentage.toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<FlashcardPracticeCubit>().resetPractice(),
              icon: const Icon(Icons.refresh),
              label: const Text('Practice Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
