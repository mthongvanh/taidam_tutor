import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/data/characters/models/character_class.dart';
import 'package:taidam_tutor/feature/alphabet_practice/character_drill_page.dart';
import 'package:taidam_tutor/feature/alphabet_practice/widgets/character_intro_card.dart';

class CharacterIntroductionPage extends StatefulWidget {
  final List<Character> characters;
  final CharacterClass characterClass;
  final Map<CharacterClass, List<Character>> characterGroups;

  const CharacterIntroductionPage({
    super.key,
    required this.characters,
    required this.characterClass,
    required this.characterGroups,
  });

  @override
  State<CharacterIntroductionPage> createState() =>
      _CharacterIntroductionPageState();
}

class _CharacterIntroductionPageState extends State<CharacterIntroductionPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < widget.characters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getClassTitle()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.characters.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
            ),

            // Character cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.characters.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: CharacterIntroCard(
                      character: widget.characters[index],
                      onNext: _currentIndex < widget.characters.length - 1
                          ? _goToNext
                          : null,
                      onPrevious: _currentIndex > 0 ? _goToPrevious : null,
                      currentIndex: _currentIndex,
                      totalCount: widget.characters.length,
                    ),
                  );
                },
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Exit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentIndex == widget.characters.length - 1
                          ? () {
                              // Navigate to practice/drill mode
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CharacterDrillPage(
                                    characters: widget.characters,
                                    characterClass: widget.characterClass,
                                    characterGroups: widget.characterGroups,
                                  ),
                                ),
                              );
                            }
                          : _goToNext,
                      child: Text(
                        _currentIndex == widget.characters.length - 1
                            ? 'Start Practice'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getClassTitle() {
    return 'Learn ${widget.characterClass.title}';
  }
}
