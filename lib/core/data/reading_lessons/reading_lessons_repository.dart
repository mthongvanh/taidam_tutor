import 'package:flutter/foundation.dart';

import 'reading_lessons_local_data_source.dart';
import 'reading_lessons_remote_data_source.dart';

class ReadingLessonsRepository {
  ReadingLessonsRepository({
    ReadingLessonsLocalDataSource? localDataSource,
    ReadingLessonsRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource ?? ReadingLessonsLocalDataSource(),
        _remoteDataSource =
            remoteDataSource ?? ReadingLessonsRemoteDataSource();

  final ReadingLessonsLocalDataSource _localDataSource;
  final ReadingLessonsRemoteDataSource _remoteDataSource;
  List<Map<String, dynamic>>? _remoteLessonsCache;

  /// Attempts to warm the remote cache so that UI reads return immediately.
  Future<void> prefetchRemoteLessons() async {
    await _getRemoteLessons();
  }

  Future<List<Map<String, dynamic>>> getLessons(
      {bool preferRemote = true}) async {
    if (preferRemote) {
      final remoteLessons = await _getRemoteLessons();
      if (remoteLessons != null) {
        return remoteLessons;
      }
      debugPrint('ReadingLessonsRepository: using bundled lessons fallback.');
    }

    return _localDataSource.getLessons();
  }

  Future<Map<String, dynamic>?> getLessonByNumber(
    int lessonNumber, {
    bool preferRemote = true,
  }) async {
    final lessons = await getLessons(preferRemote: preferRemote);
    for (final lesson in lessons) {
      final meta = lesson['lesson'];
      if (meta is Map<String, dynamic>) {
        final number = meta['number'];
        if (number is int && number == lessonNumber) {
          return lesson;
        }
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> _getRemoteLessons() async {
    if (_remoteLessonsCache != null) {
      return _cloneLessons(_remoteLessonsCache!);
    }

    final fetched = await _tryFetchRemoteLessons();
    if (fetched == null) {
      return null;
    }

    _remoteLessonsCache = fetched;
    return _cloneLessons(fetched);
  }

  Future<List<Map<String, dynamic>>?> _tryFetchRemoteLessons() async {
    try {
      return await _remoteDataSource.fetchLessons();
    } catch (error, stackTrace) {
      debugPrint('ReadingLessonsRepository remote fetch failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  List<Map<String, dynamic>> _cloneLessons(
    List<Map<String, dynamic>> lessons,
  ) {
    return lessons
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);
  }
}
