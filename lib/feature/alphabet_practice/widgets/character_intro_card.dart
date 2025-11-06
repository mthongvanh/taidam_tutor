import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';

class CharacterIntroCard extends StatefulWidget {
  final Character character;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showNavigation;
  final int? currentIndex;
  final int? totalCount;

  const CharacterIntroCard({
    super.key,
    required this.character,
    this.onNext,
    this.onPrevious,
    this.showNavigation = true,
    this.currentIndex,
    this.totalCount,
  });

  @override
  State<CharacterIntroCard> createState() => _CharacterIntroCardState();
}

class _CharacterIntroCardState extends State<CharacterIntroCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);

    try {
      await _audioPlayer.play(
        AssetSource('audio/${widget.character.audio}.caf'),
      );
      await _audioPlayer.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Error playing audio: $e');
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            if (widget.currentIndex != null && widget.totalCount != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.currentIndex! + 1} / ${widget.totalCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Character display
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.character.character,
                  style: TextStyle(
                    fontFamily: 'Tai Heritage Pro',
                    fontSize: 120,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sound representation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_up,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.character.sound,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Character class and properties
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoChip(
                  context,
                  widget.character.characterClass,
                  Icons.category,
                ),
                if (widget.character.highLow != null)
                  _buildInfoChip(
                    context,
                    '${widget.character.highLow} class',
                    Icons.trending_up,
                  ),
                if (widget.character.prePost != null)
                  _buildInfoChip(
                    context,
                    '${widget.character.prePost} position',
                    Icons.place,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Play audio button
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : _playAudio,
              icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
              label: Text(_isPlaying ? 'Playing...' : 'Play Sound'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Navigation buttons
            if (widget.showNavigation) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: widget.onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  TextButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
