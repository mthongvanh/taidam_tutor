import 'package:equatable/equatable.dart';

/// Represents a learning goal for a lesson
class LessonGoal extends Equatable {
  final String letter;
  final String sound;
  final String description;

  const LessonGoal({
    required this.letter,
    required this.sound,
    required this.description,
  });

  factory LessonGoal.fromJson(Map<String, dynamic> json) {
    return LessonGoal(
      letter: json['letter'] as String,
      sound: (json['sound'] ?? json['sounds']) as String,
      description: json['description'] as String,
    );
  }

  @override
  List<Object?> get props => [letter, sound, description];
}

/// Represents a character combination in a lesson
class Combination extends Equatable {
  final List<String> components;
  final String result;
  final String romanization;
  final String description;

  const Combination({
    required this.components,
    required this.result,
    required this.romanization,
    required this.description,
  });

  factory Combination.fromJson(Map<String, dynamic> json) {
    return Combination(
      components: (json['components'] as List).cast<String>(),
      result: json['result'] as String,
      romanization: json['romanization'] as String,
      description: json['description'] as String,
    );
  }

  @override
  List<Object?> get props => [components, result, romanization, description];
}

/// Represents an example word in a lesson
class Example extends Equatable {
  final String word;
  final String romanization;

  const Example({
    required this.word,
    required this.romanization,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      word: json['word'] as String,
      romanization: json['romanization'] as String,
    );
  }

  @override
  List<Object?> get props => [word, romanization];
}

/// Represents a complete reading lesson
class ReadingLesson extends Equatable {
  final int number;
  final String title;
  final String? titleRomanization;
  final String description;
  final String shortDescription;
  final List<LessonGoal> goals;
  final List<Combination> combinations;
  final List<Example>? examples;

  const ReadingLesson({
    required this.number,
    required this.title,
    this.titleRomanization,
    required this.description,
    required this.shortDescription,
    required this.goals,
    required this.combinations,
    this.examples,
  });

  factory ReadingLesson.fromJson(Map<String, dynamic> json) {
    final lessonData = json['lesson'] as Map<String, dynamic>;
    return ReadingLesson(
      number: lessonData['number'] as int,
      title: lessonData['title'] as String,
      titleRomanization: lessonData['titleRomanization'] as String?,
      description: lessonData['description'] as String,
      shortDescription: (lessonData['shortDescription'] as String?) ??
          (lessonData['description'] as String),
      goals: (lessonData['goals'] as List)
          .map((g) => LessonGoal.fromJson(g as Map<String, dynamic>))
          .toList(),
      combinations: (lessonData['combinations'] as List)
          .map((c) => Combination.fromJson(c as Map<String, dynamic>))
          .toList(),
      examples: lessonData['examples'] != null
          ? (lessonData['examples'] as List)
              .map((e) => Example.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        number,
        title,
        titleRomanization,
        description,
        shortDescription,
        goals,
        combinations,
        examples,
      ];
}
