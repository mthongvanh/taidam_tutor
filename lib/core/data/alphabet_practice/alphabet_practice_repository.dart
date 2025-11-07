import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/character_mastery.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/learning_session.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/models/achievement.dart';

class AlphabetPracticeRepository {
  static const String _masteryKey = 'character_mastery_data';
  static const String _sessionsKey = 'learning_sessions_data';
  static const String _achievementsKey = 'unlocked_achievements';

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  /// Initialize the repository
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Get mastery data for all characters
  Future<Map<int, CharacterMastery>> getAllMasteryData() async {
    await init();
    final jsonString = _prefs?.getString(_masteryKey);
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return decoded.map((key, value) =>
          MapEntry(int.parse(key), CharacterMastery.fromJson(value)));
    } catch (e) {
      return {};
    }
  }

  /// Get mastery data for a specific character
  Future<CharacterMastery?> getMasteryData(int characterId) async {
    final allData = await getAllMasteryData();
    return allData[characterId];
  }

  /// Save mastery data for a character
  Future<void> saveMasteryData(CharacterMastery mastery) async {
    await init();
    final allData = await getAllMasteryData();
    allData[mastery.characterId] = mastery;

    final encoded = json.encode(
      allData.map((key, value) => MapEntry(key.toString(), value.toJson())),
    );
    await _prefs?.setString(_masteryKey, encoded);
  }

  /// Save multiple mastery records at once
  Future<void> saveBatchMasteryData(List<CharacterMastery> masteryList) async {
    await init();
    final allData = await getAllMasteryData();
    for (final mastery in masteryList) {
      allData[mastery.characterId] = mastery;
    }

    final encoded = json.encode(
      allData.map((key, value) => MapEntry(key.toString(), value.toJson())),
    );
    await _prefs?.setString(_masteryKey, encoded);
  }

  /// Get all learning sessions
  Future<List<LearningSession>> getAllSessions() async {
    await init();
    final jsonString = _prefs?.getString(_sessionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => LearningSession.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a learning session
  Future<void> saveSession(LearningSession session) async {
    await init();
    final sessions = await getAllSessions();

    // Update existing session or add new one
    final index = sessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    final encoded = json.encode(sessions.map((e) => e.toJson()).toList());
    await _prefs?.setString(_sessionsKey, encoded);
  }

  /// Get recent sessions (last 30 days)
  Future<List<LearningSession>> getRecentSessions({int days = 30}) async {
    final sessions = await getAllSessions();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return sessions
        .where((session) => session.startTime.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Clear all progress data (for testing or reset)
  Future<void> clearAllData() async {
    await init();
    await _prefs?.remove(_masteryKey);
    await _prefs?.remove(_sessionsKey);
  }

  /// Get overall statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final masteryData = await getAllMasteryData();
    final sessions = await getAllSessions();

    int totalCharacters = masteryData.length;
    int masteredCharacters =
        masteryData.values.where((m) => m.isMastered).length;
    int totalAttempts =
        masteryData.values.fold(0, (sum, m) => sum + m.totalAttempts);
    int totalCorrect =
        masteryData.values.fold(0, (sum, m) => sum + m.correctAttempts);
    double overallAccuracy =
        totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0;

    return {
      'totalCharacters': totalCharacters,
      'masteredCharacters': masteredCharacters,
      'totalAttempts': totalAttempts,
      'totalCorrect': totalCorrect,
      'overallAccuracy': overallAccuracy,
      'totalSessions': sessions.length,
    };
  }

  /// Get all unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    await init();
    final jsonString = _prefs?.getString(_achievementsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => Achievement.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save an unlocked achievement
  Future<void> unlockAchievement(Achievement achievement) async {
    await init();
    final achievements = await getUnlockedAchievements();

    // Check if already unlocked
    if (achievements.any((a) => a.type == achievement.type)) {
      return;
    }

    achievements.add(achievement.unlock());
    final encoded = json.encode(achievements.map((e) => e.toJson()).toList());
    await _prefs?.setString(_achievementsKey, encoded);
  }

  /// Check if an achievement is unlocked
  Future<bool> isAchievementUnlocked(AchievementType type) async {
    final achievements = await getUnlockedAchievements();
    return achievements.any((a) => a.type == type);
  }

  /// Get all achievements (both locked and unlocked)
  Future<List<Achievement>> getAllAchievementsWithStatus() async {
    final unlocked = await getUnlockedAchievements();
    final unlockedTypes = unlocked.map((a) => a.type).toSet();

    return Achievement.getAllAchievements().map((achievement) {
      if (unlockedTypes.contains(achievement.type)) {
        final unlockedVersion =
            unlocked.firstWhere((a) => a.type == achievement.type);
        return unlockedVersion;
      }
      return achievement;
    }).toList();
  }
}
