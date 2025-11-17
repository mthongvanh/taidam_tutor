import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/character_drill_cubit.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/character_drill_state.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/drill_completion_card.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

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
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: state.questionNumber / state.totalQuestions,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Question ${state.questionNumber} of ${state.totalQuestions}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What sound does this character make?',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Display the target character
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  state.targetCharacter.character,
                  style: const TextStyle(
                    fontFamily: 'Tai Heritage Pro',
                    fontSize: 100,
                  ),
                ),
                if (state.targetCharacter.audio?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _playAudio(state.targetCharacter.audio ?? ''),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Hint'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Select the correct sound:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options grid - showing only sounds
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: state.options.map((character) {
                  final isSelected =
                      _selectedCharacter?.characterId == character.characterId;

                  return _buildSoundOptionButton(
                    context,
                    character,
                    isSelected,
                    theme,
                  );
                }).toList(),
              ),
            ),
          ),

          // Stats footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Correct',
                  '${state.correctAnswers}',
                  Icons.check_circle,
                  theme.colorScheme.primary,
                ),
                _buildStatItem(
                  context,
                  'Accuracy',
                  '${(state.accuracy * 100).toInt()}%',
                  Icons.trending_up,
                  theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnsweredView(
    BuildContext context,
    CharacterDrillAnswered state,
    ThemeData theme,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: state.questionNumber / state.totalQuestions,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),

          // Feedback message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: state.isCorrect
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.errorContainer.withOpacity(0.3),
            child: Column(
              children: [
                Icon(
                  state.isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: state.isCorrect
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.isCorrect ? 'Correct!' : 'Incorrect',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.isCorrect
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
                if (!state.isCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    'The correct answer is "${state.targetCharacter.romanization ?? ''}"',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Show the character with feedback
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: state.isCorrect
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.isCorrect
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  state.targetCharacter.character,
                  style: const TextStyle(
                    fontFamily: 'Tai Heritage Pro',
                    fontSize: 80,
                  ),
                ),
                const SizedBox(height: 16),
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
          ),

          const SizedBox(height: 24),

          // Options grid with feedback - showing only sounds
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: state.options.map((character) {
                  final isSelected = character.characterId ==
                      state.selectedCharacter.characterId;
                  final isCorrectAnswer = character.characterId ==
                      state.targetCharacter.characterId;

                  return _buildSoundOptionButtonWithFeedback(
                    context,
                    character,
                    isSelected,
                    isCorrectAnswer,
                    theme,
                  );
                }).toList(),
              ),
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCharacter = null;
                });
                context.read<CharacterDrillCubit>().nextQuestion();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Continue',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
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
                : theme.colorScheme.outline.withOpacity(0.3),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
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
