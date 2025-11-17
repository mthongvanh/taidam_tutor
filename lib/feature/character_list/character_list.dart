import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/feature/character_list/cubit/character_list_cubit.dart';
import 'package:taidam_tutor/feature/character_list/cubit/character_list_state.dart';
import 'package:taidam_tutor/feature/flashcard/flashcard_screen.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/utils/extensions/text_ext.dart';

class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/png/flag.png',
          ),
        ),
        title: TaiText.appBarTitle(
          'Tai Dam Characters',
          context,
        ),
      ),
      body: BlocProvider<CharacterListCubit>(
        create: (context) => CharacterListCubit(),
        child: const CharacterListView(),
      ),
    );
  }
}

class CharacterListView extends StatelessWidget {
  const CharacterListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterListCubit, CharacterListState>(
      builder: (context, state) {
        if (state is CharacterInitial || state is CharacterLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CharacterError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}'),
            ),
          );
        } else if (state is CharacterLoaded) {
          if (state.consonants.isEmpty &&
              state.vowels.isEmpty &&
              state.specialCharacters.isEmpty) {
            return const Center(child: Text('No characters found.'));
          }
          return CustomScrollView(
            slivers: [
              _buildCharacterGroup(context, 'Consonants', state.consonants),
              _buildCharacterGroup(context, 'Vowels', state.vowels),
              _buildCharacterGroup(context, 'Vowel Finals', state.vowelFinals),
              _buildCharacterGroup(
                  context, 'Vowel Combinations', state.vowelCombinations),
              _buildCharacterGroup(
                  context, 'Special Characters', state.specialCharacters),
            ],
          );
        }
        return const Center(child: Text('An unknown error occurred.'));
      },
    );
  }

  Widget _buildCharacterGroup(
    BuildContext context,
    String title,
    List<Character> characters,
  ) {
    if (characters.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Ensures at least 4 items per row
              childAspectRatio: 1.0, // Makes cells square-like
              mainAxisSpacing: 8.0, // Spacing between rows
              crossAxisSpacing: 8.0, // Spacing between columns
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final character = characters[index];
                return _CharacterListCard(
                  character: character,
                  onTap: () {
                    showBottomSheet(
                      context: context,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          initialChildSize: 1.0,
                          builder: (ctx, controller) =>
                              CharacterFlashcardsScreen(
                            characterModel: character,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              childCount: characters.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterListCard extends StatelessWidget {
  const _CharacterListCard({
    required this.character,
    this.onTap,
  });

  final Character character;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TaiCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                character.character,
                style: const TextStyle(
                  fontSize: 24, // Adjusted for grid cell
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4), // Spacing between character and sound
              Text(
                character.romanization ?? '',
                style: TextStyle(
                  fontSize: 14, // Adjusted for grid cell
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Handle long sounds
              ),
            ],
          ),
        ),
      ),
    );
  }
}
