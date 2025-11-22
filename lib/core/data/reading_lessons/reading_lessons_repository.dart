import 'reading_lessons_local_data_source.dart';

class ReadingLessonsRepository {
  final ReadingLessonsLocalDataSource _localDataSource;

  ReadingLessonsRepository()
      : _localDataSource = ReadingLessonsLocalDataSource()..init();

  Future<List<Map<String, dynamic>>> getLessons() {
    return _localDataSource.getLessons();
  }

  Future<Map<String, dynamic>?> getLessonByNumber(int lessonNumber) async {
    final lessons = await _localDataSource.getLessons();
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
}
