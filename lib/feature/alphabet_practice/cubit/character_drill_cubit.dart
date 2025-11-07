import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/achievement.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/learning_session.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/services/character_grouping_service.dart';
import 'package:taidam_tutor/core/services/spaced_repetition_service.dart';
import 'package:taidam_tutor/feature/alphabet_practice/cubit/character_drill_state.dart';
import 'package:uuid/uuid.dart';

class CharacterDrillCubit extends Cubit<CharacterDrillState> {
  final AlphabetPracticeRepository _practiceRepository;
  final List<Character> _characters;
  final String _characterClass;
  final Random _random = Random();
  final Map<String, List<Character>> _characterGroups;

  List<Character> _remainingCharacters = [];
  int _currentQuestionNumber = 0;
  int _correctAnswers = 0;
  int _totalAttempts = 0;
  String? _sessionId;

  CharacterDrillCubit({
    required AlphabetPracticeRepository practiceRepository,
    required List<Character> characters,
    required String characterClass,
    required Map<String, List<Character>> characterGroups,
  })  : _practiceRepository = practiceRepository,
        _characters = characters,
        _characterClass = characterClass,
        _characterGroups = characterGroups,
        super(const CharacterDrillInitial());

  /// Initialize the drill session
  Future<void> init({int questionsPerSession = 10}) async {
    if (_characters.isEmpty) {
      emit(const CharacterDrillError('No characters available for practice'));
      return;
    }

    emit(const CharacterDrillLoading());

    try {
      await _practiceRepository.init();

      // Create new session
      _sessionId = const Uuid().v4();
      final session = LearningSession(
        sessionId: _sessionId!,
        startTime: DateTime.now(),
        characterClass: _characterClass,
        characterIds: _characters.map((c) => c.characterId).toList(),
      );
      await _practiceRepository.saveSession(session);

      // Shuffle and prepare character list
      _remainingCharacters = List.from(_characters)..shuffle(_random);

      // Limit to questionsPerSession
      if (_remainingCharacters.length > questionsPerSession) {
        _remainingCharacters =
            _remainingCharacters.sublist(0, questionsPerSession);
      }

      _currentQuestionNumber = 0;
      _correctAnswers = 0;
      _totalAttempts = 0;

      _presentNextQuestion();
    } catch (e) {
      emit(CharacterDrillError('Failed to initialize drill: $e'));
    }
  }

  /// Present the next question
  void _presentNextQuestion() {
    if (_remainingCharacters.isEmpty) {
      _completeDrill();
      return;
    }

    _currentQuestionNumber++;
    final targetCharacter = _remainingCharacters.removeAt(0);

    // Generate options (target + 3 distractors)
    final distractors = CharacterGroupingService.getSimilarCharacters(
      targetCharacter,
      _characters,
      count: 3,
    );

    final options = [targetCharacter, ...distractors]..shuffle(_random);

    emit(CharacterDrillQuestion(
      targetCharacter: targetCharacter,
      options: options,
      questionNumber: _currentQuestionNumber,
      totalQuestions: _currentQuestionNumber + _remainingCharacters.length,
      correctAnswers: _correctAnswers,
      totalAttempts: _totalAttempts,
    ));
  }

  /// User selected an answer
  Future<void> selectAnswer(Character selectedCharacter) async {
    final currentState = state;
    if (currentState is! CharacterDrillQuestion) return;

    final isCorrect = selectedCharacter.characterId ==
        currentState.targetCharacter.characterId;

    _totalAttempts++;
    if (isCorrect) {
      _correctAnswers++;
    }

    // Record the attempt in mastery data
    await _recordAttempt(
      currentState.targetCharacter.characterId,
      isCorrect,
    );

    // Update session
    if (_sessionId != null) {
      final sessions = await _practiceRepository.getAllSessions();
      final session = sessions.firstWhere((s) => s.sessionId == _sessionId);
      final updatedSession = session.recordAnswer(correct: isCorrect);
      await _practiceRepository.saveSession(updatedSession);
    }

    emit(CharacterDrillAnswered(
      targetCharacter: currentState.targetCharacter,
      selectedCharacter: selectedCharacter,
      options: currentState.options,
      isCorrect: isCorrect,
      questionNumber: currentState.questionNumber,
      totalQuestions: currentState.totalQuestions,
      correctAnswers: _correctAnswers,
      totalAttempts: _totalAttempts,
    ));
  }

  /// Continue to next question after viewing feedback
  void nextQuestion() {
    final currentState = state;
    if (currentState is CharacterDrillAnswered) {
      _presentNextQuestion();
    }
  }

  /// Record attempt in mastery data
  Future<void> _recordAttempt(int characterId, bool correct) async {
    try {
      var mastery = await _practiceRepository.getMasteryData(characterId);

      mastery ??= CharacterMastery(
        characterId: characterId,
        lastPracticed: DateTime.now(),
      );

      mastery = mastery.recordAttempt(correct: correct);
      await _practiceRepository.saveMasteryData(mastery);
    } catch (e) {
      // Log error but don't fail the drill
      print('Error recording attempt: $e');
    }
  }

  /// Complete the drill session
  void _completeDrill() async {
    final accuracy =
        _totalAttempts > 0 ? _correctAnswers / _totalAttempts : 0.0;

    // End the session
    if (_sessionId != null) {
      try {
        final sessions = await _practiceRepository.getAllSessions();
        final session = sessions.firstWhere((s) => s.sessionId == _sessionId);
        final endedSession = session.endSession();
        await _practiceRepository.saveSession(endedSession);

        // Check for newly unlocked achievements
        final newlyUnlocked = await _checkAchievements(accuracy);

        emit(CharacterDrillCompleted(
          totalQuestions: _totalAttempts,
          correctAnswers: _correctAnswers,
          accuracy: accuracy,
          characterClass: _characterClass,
          newlyUnlockedAchievements: newlyUnlocked,
        ));
      } catch (e) {
        print('Error ending session: $e');
        emit(CharacterDrillCompleted(
          totalQuestions: _totalAttempts,
          correctAnswers: _correctAnswers,
          accuracy: accuracy,
          characterClass: _characterClass,
        ));
      }
    } else {
      emit(CharacterDrillCompleted(
        totalQuestions: _totalAttempts,
        correctAnswers: _correctAnswers,
        accuracy: accuracy,
        characterClass: _characterClass,
      ));
    }
  }

  /// Check for achievements and unlock new ones
  Future<List<Achievement>> _checkAchievements(double sessionAccuracy) async {
    try {
      final completedSessions = (await _practiceRepository.getAllSessions())
          .where((s) => !s.isActive)
          .toList();
      final stats = await _practiceRepository.getOverallStats();
      final masteryData = await _practiceRepository.getAllMasteryData();

      // Calculate streak
      final practiceDates = completedSessions.map((s) => s.startTime).toList();
      final streak =
          SpacedRepetitionService.calculatePracticeStreak(practiceDates);

      // Check if had perfect session
      final hadPerfectSession = sessionAccuracy >= 1.0;

      // Get mastered counts by class
      final consonants = _characterGroups['consonant'] ?? [];
      final vowels = _characterGroups['vowel'] ?? [];
      final masteredConsonants = consonants
          .where((c) => masteryData[c.characterId]?.isMastered ?? false)
          .length;
      final masteredVowels = vowels
          .where((c) => masteryData[c.characterId]?.isMastered ?? false)
          .length;

      // Check which achievements should be unlocked
      final unlockedTypes = Achievement.checkAchievements(
        totalSessions: completedSessions.length,
        masteredCharacters: stats['masteredCharacters'] ?? 0,
        totalCorrectAnswers: stats['totalCorrect'] ?? 0,
        practiceStreak: streak,
        hadPerfectSession: hadPerfectSession,
        masteredConsonants: masteredConsonants,
        masteredVowels: masteredVowels,
        totalConsonants: consonants.length,
        totalVowels: vowels.length,
      );

      // Get all achievements
      final allAchievements = Achievement.getAllAchievements();
      final newlyUnlocked = <Achievement>[];

      for (final type in unlockedTypes) {
        // Check if already unlocked
        final isAlreadyUnlocked =
            await _practiceRepository.isAchievementUnlocked(type);
        if (!isAlreadyUnlocked) {
          final achievement = allAchievements.firstWhere((a) => a.type == type);
          await _practiceRepository.unlockAchievement(achievement);
          newlyUnlocked.add(achievement.unlock());
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  /// Skip to completion (for testing or early exit)
  void skipToCompletion() {
    _remainingCharacters.clear();
    _completeDrill();
  }
}
