import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taidam_tutor/feature/letter_search/cubit/letter_search_cubit.dart';
import 'package:taidam_tutor/feature/letter_search/cubit/letter_search_state.dart';
import 'package:taidam_tutor/feature/letter_search/widgets/letter_grid/core/data/models/grid_cell.dart';
import 'package:taidam_tutor/utils/extensions/card_ext.dart';
import 'package:taidam_tutor/utils/extensions/text_ext.dart';
import 'package:taidam_tutor/widgets/error/tai_error.dart';

class LetterGrid extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const LetterGrid(
    this.audioPlayer, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LetterSearchCubit, LetterSearchState>(
          buildWhen: (prev, curr) =>
              prev.targetLetter != curr.targetLetter ||
              prev.isLoading != curr.isLoading,
          builder: (context, state) {
            if (state.isLoading && state.targetLetter == null) {
              return TaiText.appBarTitle(
                'Character Search Game',
                context,
              );
            }
            return TaiText.appBarTitle(
                state.targetLetter == null
                    ? 'Character Search Game'
                    : state.searchMode == SearchMode.singleCharacter
                        ? 'Find'
                        : 'Find words containing',
                context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () {
              context.read<LetterSearchCubit>().changeSearchMode();
            },
          ),
        ],
      ),
      body: BlocListener<LetterSearchCubit, LetterSearchState>(
        listener: (context, state) {
          // Assuming your LetterSearchState has a 'gameWon' boolean property
          // You'll need to add this property to your LetterSearchState
          // and update it in your LetterSearchCubit when all letters are found.
          if (state.gameWon) {
            // Replace 'gameWon' with your actual property name
            _showWinDialog(context);
          }
        },
        child: BlocBuilder<LetterSearchCubit, LetterSearchState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return TaiError(
                onRetry: () => context.read<LetterSearchCubit>().resetGrid(),
              );
            }

            if (state.grid.isEmpty && !state.isLoading) {
              return TaiError(
                // 'Grid not initialized. Please ensure parameters are correct and try resetting.',
                onRetry: () => context.read<LetterSearchCubit>().resetGrid(),
              );
            }

            if (state.grid.isEmpty) {
              // Should be caught by above, but as a fallback
              return TaiError(
                // 'No grid to display.',
                onRetry: () => context.read<LetterSearchCubit>().resetGrid(),
              );
            }

            double screenWidth = MediaQuery.of(context).size.width;
            double cellSize = (screenWidth * 0.8) / state.gridSize;
            // Ensure minimum cell size for very small screens or large grids
            cellSize = cellSize < 30.0 ? 30.0 : cellSize;
            double fontSize = cellSize * 0.25;

            return Column(
              spacing: 16,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: cellSize * 1.5,
                        height: cellSize * 1.5,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.loose,
                          children: [
                            Text(
                              state.targetLetter?.character ?? '',
                              style: const TextStyle(
                                fontSize: 70,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.play_circle),
                                onPressed: () {
                                  if (state.targetLetter?.audio != null) {
                                    audioPlayer.play(
                                      AssetSource(
                                        'audio/${state.targetLetter?.audio}.caf',
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'sounds like "${state.targetLetter?.romanization ?? '(whoops! no sound found)'}"',
                        style: const TextStyle(
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: state.grid.asMap().entries.map((rowEntry) {
                          int rowIndex = rowEntry.key;
                          List<GridCell> row = rowEntry.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: row.asMap().entries.map((cellEntry) {
                              int colIndex = cellEntry.key;
                              GridCell cell = cellEntry.value;
                              Color backgroundColor;
                              if (cell.isTarget && cell.isRevealed) {
                                backgroundColor = Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer;
                              } else {
                                backgroundColor = Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer;
                              }

                              return _SearchGridItem(
                                rowIndex: rowIndex,
                                colIndex: colIndex,
                                cellSize: cellSize,
                                backgroundColor: backgroundColor,
                                cell: cell,
                                fontSize: fontSize,
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<LetterSearchCubit>().resetGrid();
        },
        tooltip: 'New Grid (Same Settings)',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Congratulations!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Card(
                clipBehavior: Clip.hardEdge,
                shadowColor: Colors.black38,
                elevation: 6.0,
                child: Image.asset(
                  'assets/images/png/celebrate.png',
                  width: 200,
                  height: 200,
                ),
              ),
              Text(
                'You found them all!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Reset the grid by calling the cubit method
                context.read<LetterSearchCubit>().resetGrid();
              },
            ),
          ],
        );
      },
    );
  }
}

class _SearchGridItem extends StatelessWidget {
  const _SearchGridItem({
    required this.rowIndex,
    required this.colIndex,
    required this.cellSize,
    required this.backgroundColor,
    required this.cell,
    required this.fontSize,
  });

  final int rowIndex;
  final int colIndex;
  final double cellSize;
  final Color backgroundColor;
  final GridCell cell;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Check if the game is already won to prevent interaction
        if (context.read<LetterSearchCubit>().state.gameWon) {
          return;
        }
        context.read<LetterSearchCubit>().cellTapped(rowIndex, colIndex);
      },
      child: TaiCard(
        child: Container(
          color: backgroundColor,
          width: cellSize,
          height: cellSize,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              cell.letter,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
