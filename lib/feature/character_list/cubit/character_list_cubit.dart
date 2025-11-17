import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/characters/character_repository.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/character_list/cubit/character_list_state.dart';

class CharacterListCubit extends Cubit<CharacterListState> {
  final CharacterRepository _repository;

  CharacterListCubit()
      : _repository = dm.get<CharacterRepository>(),
        super(CharacterInitial()) {
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    try {
      emit(CharacterLoading());
      final characters = await _repository.getCharacters();

    final consonants = characters
      .where((c) => c.characterClass == CharacterClass.consonant)
      .toList();
    final vowels = characters
      .where((c) => c.characterClass == CharacterClass.vowel)
      .toList();
    final specialCharacters = characters
      .where((c) => c.characterClass == CharacterClass.special)
      .toList();

      final vowelFinals = <Character>[];
      final vowelCombinations = <Character>[];
      if (vowels.isNotEmpty) {
        characters.where((c) => c.position == "after").toList();
        characters.where((c) => c.position == "split").toList();
      }

      // Optionally, sort each list if needed (e.g., by sound or a specific order)
      consonants.sort((a, b) => a.characterId.compareTo(b.characterId));
      vowels.sort((a, b) => a.characterId.compareTo(b.characterId));
      vowelFinals.sort((a, b) => a.characterId.compareTo(b.characterId));
      vowelCombinations.sort((a, b) => a.characterId.compareTo(b.characterId));
      specialCharacters.sort((a, b) => a.characterId.compareTo(b.characterId));

      emit(CharacterLoaded(
        consonants: consonants,
        vowels: vowels,
        vowelFinals: vowelFinals,
        vowelCombinations: vowelCombinations,
        specialCharacters: specialCharacters,
      ));
    } catch (e) {
      emit(CharacterError("Failed to load characters: ${e.toString()}"));
    }
  }
}
