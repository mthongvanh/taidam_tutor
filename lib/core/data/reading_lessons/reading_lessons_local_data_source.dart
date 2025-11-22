import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ReadingLessonsLocalDataSource {
  List<Map<String, dynamic>> _lessons = const [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/reading_lessons.json');
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
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
      _isInitialized = false;
    }
  }

  Future<List<Map<String, dynamic>>> getLessons() async {
    if (!_isInitialized) {
      await init();
    }
    return List<Map<String, dynamic>>.from(_lessons);
  }
}
