class ReadingLessonsPayload {
  final List<Map<String, dynamic>> lessons;
  final DateTime? lastUpdated;

  const ReadingLessonsPayload({
    required this.lessons,
    required this.lastUpdated,
  });
}
