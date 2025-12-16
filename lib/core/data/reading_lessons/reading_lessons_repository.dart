import 'package:flutter/foundation.dart';

import 'reading_lessons_local_data_source.dart';
import 'reading_lessons_payload.dart';
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
  ReadingLessonsPayload? _localLessonsCache;
  ReadingLessonsPayload? _remoteLessonsCache;

  /// Attempts to warm the remote cache so that UI reads return immediately.
  Future<void> prefetchRemoteLessons() async {
    await _getRemoteLessons();
  }

  Future<List<Map<String, dynamic>>> getLessons(
      {bool preferRemote = true}) async {
    final localPayload = await _getLocalLessons();

    if (preferRemote) {
      final remotePayload = await _getRemoteLessons();
      if (remotePayload != null) {
        if (_shouldUseRemote(remotePayload, localPayload)) {
          return _cloneLessons(remotePayload.lessons);
        }
      } else {
        debugPrint('ReadingLessonsRepository: using bundled lessons fallback.');
      }
    }

    return _cloneLessons(localPayload.lessons);
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

  Future<ReadingLessonsPayload> _getLocalLessons() async {
    _localLessonsCache ??= await _localDataSource.getLessons();
    return _clonePayload(_localLessonsCache!);
  }

  Future<ReadingLessonsPayload?> _getRemoteLessons() async {
    if (_remoteLessonsCache != null) {
      return _clonePayload(_remoteLessonsCache!);
    }

    final fetched = await _tryFetchRemoteLessons();
    if (fetched == null) {
      return null;
    }

    _remoteLessonsCache = fetched;
    return _clonePayload(fetched);
  }

  Future<ReadingLessonsPayload?> _tryFetchRemoteLessons() async {
    try {
      return await _remoteDataSource.fetchLessons();
    } catch (error, stackTrace) {
      debugPrint('ReadingLessonsRepository remote fetch failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  ReadingLessonsPayload _clonePayload(ReadingLessonsPayload payload) {
    return ReadingLessonsPayload(
      lessons: _cloneLessons(payload.lessons),
      lastUpdated: payload.lastUpdated,
    );
  }

  List<Map<String, dynamic>> _cloneLessons(
    List<Map<String, dynamic>> lessons,
  ) {
    return lessons
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);
  }

  bool _shouldUseRemote(
    ReadingLessonsPayload remote,
    ReadingLessonsPayload local,
  ) {
    final remoteUpdated = remote.lastUpdated;
    final localUpdated = local.lastUpdated;

    if (remoteUpdated == null && localUpdated == null) {
      return remote.lessons.isNotEmpty;
    }

    if (remoteUpdated == null) {
      return false;
    }

    if (localUpdated == null) {
      return true;
    }

    if (remoteUpdated.isAfter(localUpdated)) {
      return true;
    }

    final updatesMatch = remoteUpdated.isAtSameMomentAs(localUpdated);
    if (updatesMatch && local.lessons.isEmpty && remote.lessons.isNotEmpty) {
      return true;
    }

    return false;
  }
}
