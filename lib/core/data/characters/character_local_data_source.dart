import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';

class CharacterLocalDataSource {
  List<Character> _characters = [];
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/characters.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _characters = jsonList.map((json) => Character.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e, stackTrace) {
      _characters = [];
      debugPrint('Error loading characters: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<List<Character>> getCharacters() async {
    if (!_isInitialized) {
      await init();
    }
    return _characters.toList();
  }
}
