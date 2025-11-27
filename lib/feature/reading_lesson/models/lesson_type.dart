enum LessonType {
  defaultFlow('default'),
  wordIdentification('word-identification');

  const LessonType(this.key);

  final String key;

  static LessonType fromKey(String? raw) {
    final normalized = raw?.toLowerCase().trim();
    switch (normalized) {
      case 'word-identification':
      case 'word_identification':
      case 'wordidentification':
        return LessonType.wordIdentification;
      case 'default':
      case 'default-flow':
      case 'default_flow':
      default:
        return LessonType.defaultFlow;
    }
  }

  String get displayLabel => switch (this) {
        LessonType.defaultFlow => 'Full Lesson',
        LessonType.wordIdentification => 'Word Identification',
      };
}
