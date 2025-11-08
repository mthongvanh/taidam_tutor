import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/core/services/spaced_repetition_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/analytics_page.dart';
import 'package:taidam_tutor/feature/alphabet_practice/character_drill_page.dart';
import 'package:taidam_tutor/feature/alphabet_practice/character_introduction_page.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/alphabet_practice_cubit.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/alphabet_practice_state.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/character_group_selector.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/progress_dashboard.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

class AlphabetPracticePage extends StatelessWidget {
  const AlphabetPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlphabetPracticeCubit(
        characterRepository: dm.get<CharacterRepository>(),
        practiceRepository: dm.get<AlphabetPracticeRepository>(),
      )..init(),
      child: const _AlphabetPracticeView(),
    );
  }
}

class _AlphabetPracticeView extends StatelessWidget {
  const _AlphabetPracticeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet Practice'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AlphabetPracticeCubit>().refresh();
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore),
                    SizedBox(width: 8),
                    Text('Reset Progress'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AlphabetPracticeCubit, AlphabetPracticeState>(
        builder: (context, state) {
          if (state is AlphabetPracticeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlphabetPracticeError) {
            return TaiError(
              errorMessage: state.message,
              onRetry: () {
                context.read<AlphabetPracticeCubit>().init();
              },
            );
          }

          if (state is AlphabetPracticeLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AlphabetPracticeLoaded state) {
    // Calculate progress for each character class
    final classProgress = <String, double>{};
    for (final className
        in CharacterGroupingService.getRecommendedLearningOrder()) {
      classProgress[className] = state.getClassProgress(className);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Dashboard
          ProgressDashboard(
            classProgress: classProgress,
            overallProgress: state.overallProgress,
            stats: state.stats,
          ),

          const SizedBox(height: 16),

          // Analytics button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final practiceRepo = dm.get<AlphabetPracticeRepository>();
                final sessions = await practiceRepo.getAllSessions();
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AnalyticsPage(
                        sessions: sessions,
                        masteryData: state.masteryData,
                        characterGroups: state.characterGroups,
                        stats: state.stats,
                        overallProgress: state.overallProgress,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View Analytics & Achievements'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Character Group Selector
          CharacterGroupSelector(
            classProgress: classProgress,
            onClassSelected: (className, isPractice) {
              if (isPractice) {
                _navigateToPractice(context, state, className);
              } else {
                _navigateToIntroduction(context, state, className);
              }
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _navigateToPractice(
    BuildContext context,
    AlphabetPracticeLoaded state,
    String characterClass,
  ) {
    final characters = state.characterGroups[characterClass] ?? [];

    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No characters found for $characterClass'),
        ),
      );
      return;
    }

    final sessionSize =
        SpacedRepetitionService.getRecommendedSessionSize(characters.length);
    final selectedCharacters =
        SpacedRepetitionService.selectCharactersForSession(
      characters: characters,
      masteryData: state.masteryData,
      sessionSize: sessionSize,
    );

    final practiceCharacters = List<Character>.from(
      selectedCharacters.isNotEmpty
          ? selectedCharacters
          : characters.take(sessionSize).toList(),
    );

    if (practiceCharacters.length < 4 && characters.length >= 4) {
      practiceCharacters
        ..clear()
        ..addAll(characters.take(sessionSize).toList());
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterDrillPage(
          characters: practiceCharacters,
          characterClass: characterClass,
          characterGroups: state.characterGroups,
        ),
      ),
    );
  }

  void _navigateToIntroduction(
    BuildContext context,
    AlphabetPracticeLoaded state,
    String characterClass,
  ) {
    final characters = state.characterGroups[characterClass] ?? [];

    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No characters found for $characterClass'),
        ),
      );
      return;
    }

    final sessionSize =
        SpacedRepetitionService.getRecommendedSessionSize(characters.length);
    final batch = SpacedRepetitionService.selectCharactersForSession(
      characters: characters,
      masteryData: state.masteryData,
      sessionSize: sessionSize,
    );

    if (batch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select characters for $characterClass'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterIntroductionPage(
          characters: batch,
          characterClass: characterClass,
          characterGroups: state.characterGroups,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AlphabetPracticeCubit>().resetProgress();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
