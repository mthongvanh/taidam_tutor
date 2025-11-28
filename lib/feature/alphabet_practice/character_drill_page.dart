import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/constants/spacing.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/character_drill_cubit.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/character_drill_state.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/drill_completion_card.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';
import 'package:taidam_tutor/widgets/quiz_practice_layout.dart';

class CharacterDrillPage extends StatelessWidget {
  final List<Character> characters;
  final CharacterClass characterClass;
  final Map<CharacterClass, List<Character>> characterGroups;

  const CharacterDrillPage({
    super.key,
    required this.characters,
    required this.characterClass,
    required this.characterGroups,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CharacterDrillCubit(
        practiceRepository: dm.get<AlphabetPracticeRepository>(),
        characters: characters,
        characterClass: characterClass,
        characterGroups: characterGroups,
      )..init(),
      child: _CharacterDrillView(characterClass: characterClass),
    );
  }
}

class _CharacterDrillView extends StatefulWidget {
  final CharacterClass characterClass;

  const _CharacterDrillView({required this.characterClass});

  @override
  State<_CharacterDrillView> createState() => _CharacterDrillViewState();
}

class _CharacterDrillViewState extends State<_CharacterDrillView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Character? _selectedCharacter;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioFile) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$audioFile.caf'));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${CharacterGroupingService.getClassTitle(widget.characterClass)} Practice',
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CharacterDrillCubit, CharacterDrillState>(
        listener: (context, state) {
          if (state is CharacterDrillAnswered) {
            // Play feedback sound or vibration
            if (state.isCorrect) {
              // Could play success sound
            } else {
              // Could play error sound
            }
          }
        },
        builder: (context, state) {
          if (state is CharacterDrillLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CharacterDrillError) {
            return TaiError(
              errorMessage: state.message,
              onRetry: () {
                context.read<CharacterDrillCubit>().init();
              },
            );
          }

          if (state is CharacterDrillQuestion) {
            return _buildQuestionView(context, state, theme);
          }

          if (state is CharacterDrillAnswered) {
            return _buildAnsweredView(context, state, theme);
          }

          if (state is CharacterDrillCompleted) {
            return _buildCompletionView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    CharacterDrillQuestion state,
    ThemeData theme,
  ) {
    return SafeArea(
      child: QuizPracticeLayout(
        currentQuestion: state.questionNumber,
        totalQuestions: state.totalQuestions,
        scoreLabel: 'Correct: ${state.correctAnswers}',
        title: 'What sound does this character make?',
        prompt: Column(
          spacing: Spacing.s,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: Spacing.l),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(77),
                  width: 2,
                ),
              ),
              child: Text(
                state.targetCharacter.character,
                style: const TextStyle(
                  fontFamily: 'Tai Heritage Pro',
                  fontSize: 100,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (state.targetCharacter.audio?.isNotEmpty ?? false)
              ElevatedButton.icon(
                onPressed: () => _playAudio(state.targetCharacter.audio ?? ''),
                icon: const Icon(Icons.volume_up),
                label: const Text('Play Sound'),
              ),
          ],
        ),
        promptPadding: EdgeInsets.zero,
        answerDescription: Text(
          'Select the correct sound:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        answerOptions: [
          _buildOptionsGrid(
            options: state.options,
            builder: (character) {
              final isSelected =
                  _selectedCharacter?.characterId == character.characterId;
              return _buildSoundOptionButton(
                context,
                character,
                isSelected,
                theme,
              );
            },
          ),
        ],
        answerExtras: [
          _DrillStatsRow(
            correctLabel: '${state.correctAnswers}',
            accuracyLabel: '${(state.accuracy * 100).toInt()}%',
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
          ),
        ],
        bottomButton: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.touch_app),
          label: const Text('Select an answer to continue'),
        ),
      ),
    );
  }

  Widget _buildAnsweredView(
    BuildContext context,
    CharacterDrillAnswered state,
    ThemeData theme,
  ) {
    return SafeArea(
      child: QuizPracticeLayout(
        currentQuestion: state.questionNumber,
        totalQuestions: state.totalQuestions,
        scoreLabel: 'Correct: ${state.correctAnswers}',
        title: 'Great job! Here’s the answer:',
        prompt: Column(
          spacing: Spacing.s,
          children: [
            Text(
              state.targetCharacter.character,
              style: const TextStyle(
                fontFamily: 'Tai Heritage Pro',
                fontSize: 80,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sound: ',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  state.targetCharacter.romanization ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.isCorrect
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
        answerDescription: Text(
          'Review the options to see which one was correct.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        answerOptions: [
          _buildOptionsGrid(
            options: state.options,
            builder: (character) {
              final isSelected =
                  character.characterId == state.selectedCharacter.characterId;
              final isCorrectAnswer =
                  character.characterId == state.targetCharacter.characterId;
              return _buildSoundOptionButtonWithFeedback(
                context,
                character,
                isSelected,
                isCorrectAnswer,
                theme,
              );
            },
          ),
        ],
        feedback: _AnsweredFeedback(isCorrect: state.isCorrect),
        answerExtras: [
          _DrillStatsRow(
            correctLabel: '${state.correctAnswers}',
            accuracyLabel: '${(state.accuracy * 100).toInt()}%',
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
          ),
        ],
        bottomButton: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _selectedCharacter = null;
            });
            context.read<CharacterDrillCubit>().nextQuestion();
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ),
    );
  }

  Widget _buildCompletionView(
    BuildContext context,
    CharacterDrillCompleted state,
  ) {
    return Center(
      child: SingleChildScrollView(
        child: DrillCompletionCard(
          totalQuestions: state.totalQuestions,
          correctAnswers: state.correctAnswers,
          accuracy: state.accuracy,
          characterClass: state.characterClass,
          newlyUnlockedAchievements: state.newlyUnlockedAchievements,
          onContinue: () => Navigator.of(context).pop(),
          onRestart: () {
            setState(() {
              _selectedCharacter = null;
            });
            context.read<CharacterDrillCubit>().init();
          },
        ),
      ),
    );
  }

  Widget _buildSoundOptionButtonWithFeedback(
    BuildContext context,
    Character character,
    bool isSelected,
    bool isCorrectAnswer,
    ThemeData theme,
  ) {
    Color? backgroundColor;
    Color? borderColor;

    if (isCorrectAnswer) {
      backgroundColor = theme.colorScheme.primaryContainer;
      borderColor = theme.colorScheme.primary;
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.errorContainer;
      borderColor = theme.colorScheme.error;
    } else {
      backgroundColor = theme.colorScheme.surface;
      borderColor = theme.colorScheme.outline.withAlpha(77);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: isSelected || isCorrectAnswer ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              character.romanization ?? '',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCorrectAnswer
                    ? theme.colorScheme.primary
                    : isSelected
                        ? theme.colorScheme.error
                        : theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isSelected || isCorrectAnswer)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isCorrectAnswer ? Icons.check_circle : Icons.cancel,
                color: isCorrectAnswer
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSoundOptionButton(
    BuildContext context,
    Character character,
    bool isSelected,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCharacter = character;
        });
        context.read<CharacterDrillCubit>().selectAnswer(character);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(77),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            character.romanization ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid({
    required List<Character> options,
    required Widget Function(Character character) builder,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: Spacing.m,
      crossAxisSpacing: Spacing.m,
      childAspectRatio: 2.5,
      children: options.map(builder).toList(),
    );
  }
}

class _DrillStatsRow extends StatelessWidget {
  const _DrillStatsRow({
    required this.correctLabel,
    required this.accuracyLabel,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String correctLabel;
  final String accuracyLabel;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
          icon: Icons.check_circle,
          label: 'Correct',
          value: correctLabel,
          color: primaryColor,
        ),
        _StatChip(
          icon: Icons.trending_up,
          label: 'Accuracy',
          value: accuracyLabel,
          color: secondaryColor,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: Spacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnsweredFeedback extends StatelessWidget {
  const _AnsweredFeedback({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isCorrect ? theme.colorScheme.primary : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(Spacing.l),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel,
              color: color, size: 48),
          const SizedBox(height: Spacing.s),
          Text(
            isCorrect ? 'Correct!' : 'Not quite this time.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            isCorrect
                ? 'Keep it up!'
                : 'Review the highlighted answer and try again.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
