import 'dart:convert';

import 'package:http/http.dart' as http;

import 'reading_lessons_payload.dart';

/// Fetches reading lessons JSON from the remote CDN endpoint.
class ReadingLessonsRemoteDataSource {
  ReadingLessonsRemoteDataSource({http.Client? client, String? endpoint})
      : _client = client ?? http.Client(),
        _endpoint = endpoint ?? _defaultEndpoint;

  final http.Client _client;
  final String _endpoint;

  static const String _defaultEndpoint =
      'https://tveye.io/taidam-tutor/assets/reading_lessons.json';

  /// Downloads and parses the remote lessons payload.
  Future<ReadingLessonsPayload> fetchLessons() async {
    final uri = Uri.parse(_endpoint);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Reading lessons request failed with ${response.statusCode}',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final timestampRaw = decoded['lastUpdated'] as String?;
    final lastUpdated =
        timestampRaw != null ? DateTime.tryParse(timestampRaw) : null;
    final lessonsJson = decoded['lessons'] as List<dynamic>? ?? const [];
    final lessons = lessonsJson
        .whereType<Map<String, dynamic>>()
        .map((lesson) => Map<String, dynamic>.from(lesson))
        .toList(growable: false);

    return ReadingLessonsPayload(
      lessons: lessons,
      lastUpdated: lastUpdated,
    );
  }
}
