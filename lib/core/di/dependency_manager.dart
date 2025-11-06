import 'package:get_it/get_it.dart';
import 'package:taidam_tutor/core/data/alphabet_practice/alphabet_practice_repository.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/flashcards/flashcard_repository.dart';

class DependencyManager {
  static final DependencyManager _instance = DependencyManager._internal();

  factory DependencyManager() {
    return _instance;
  }

  DependencyManager._internal();

  void registerDependencies() {
    GetIt.I.registerSingleton<FlashcardRepository>(FlashcardRepository());
    GetIt.I.registerSingleton<CharacterRepository>(CharacterRepository());
    GetIt.I.registerSingleton<AlphabetPracticeRepository>(
      AlphabetPracticeRepository(),
    );
  }

  T get<T extends Object>() {
    return GetIt.I<T>();
  }
}

DependencyManager dm = DependencyManager();
