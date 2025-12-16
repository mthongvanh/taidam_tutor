import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'reading_lessons_payload.dart';

class ReadingLessonsLocalDataSource {
  List<Map<String, dynamic>> _lessons = const [];
  bool _isInitialized = false;
  DateTime? _lastUpdated;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/reading_lessons.json');
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
        final timestampRaw = decoded['lastUpdated'] as String?;
        _lastUpdated =
          timestampRaw != null ? DateTime.tryParse(timestampRaw) : null;

        final lessonsJson = decoded['lessons'] as List<dynamic>? ?? const [];
      _lessons = lessonsJson
          .whereType<Map<String, dynamic>>()
          .map((lesson) => Map<String, dynamic>.from(lesson))
          .toList(growable: false);
      _isInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('Error loading reading lessons: $error');
      debugPrintStack(stackTrace: stackTrace);
      _lessons = const [];
      _lastUpdated = null;
      _isInitialized = false;
    }
  }

  Future<ReadingLessonsPayload> getLessons() async {
    if (!_isInitialized) {
      await init();
    }
    final clonedLessons = _lessons
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);
    return ReadingLessonsPayload(
      lessons: clonedLessons,
      lastUpdated: _lastUpdated,
    );
  }
}
