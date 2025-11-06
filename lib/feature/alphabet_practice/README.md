# Alphabet Practice Feature

## Overview
The Alphabet Practice feature provides a structured, progressive learning experience for mastering the Tai Dam script. It includes character introduction cards, progress tracking, and organized learning paths by character class.

## Features

### 1. Progress Dashboard
- **Overall Mastery**: Visual progress bar showing percentage of mastered characters
- **Statistics Grid**: 
  - Characters mastered (e.g., 12/45)
  - Overall accuracy percentage
  - Total practice attempts
- **Category Progress**: Individual progress bars for:
  - Consonants
  - Vowels
  - Vowel Combinations
  - Special Characters

### 2. Character Groups
Four organized learning categories:
- **Consonants**: High-class and low-class consonant sounds
- **Vowels**: Pre-positioned and post-positioned vowels
- **Vowel Combinations**: Diphthongs and complex vowel sounds
- **Special Characters**: Tone marks and other special symbols

### 3. Character Introduction
Interactive flashcard-style learning:
- Large character display in authentic Tai Dam font
- Audio pronunciation playback
- Sound approximation in English
- Character metadata (class, position, tone level)
- Swipeable cards with progress indicator
- Navigation controls (Previous/Next)

### 4. Progress Tracking
Automatic mastery tracking:
- Attempt counter per character
- Accuracy calculation
- Last practice timestamp
- Mastery threshold: 85% accuracy with 10+ attempts
- Review suggestions based on performance and recency

## User Flow

1. **Dashboard View**: See overall progress and choose a category
2. **Category Selection**: Tap a character class card to begin
3. **Introduction Session**: 
   - View characters one at a time
   - Play audio to hear pronunciation
   - Swipe or tap to navigate
   - Session limited to 10 characters at a time
4. **Progress Updates**: Mastery data automatically saved locally

## Technical Implementation

### Data Persistence
- Uses `shared_preferences` for local storage
- JSON serialization for character mastery and session data
- Automatic initialization on first use

### State Management
- BLoC pattern with Cubits
- Sealed state classes for type safety
- Reactive UI updates

### Audio Playback
- `.caf` audio files for all characters
- `audioplayers` package integration
- Loading states and error handling

### Character Organization
- `CharacterGroupingService` for filtering and grouping
- Support for character properties (high/low, pre/post)
- Configurable batch sizes for learning sessions

## Data Models

### CharacterMastery
```dart
{
  characterId: int,
  totalAttempts: int,
  correctAttempts: int,
  lastPracticed: DateTime,
  currentLevel: int // 0=intro, 1=drill, 2=speed
}
```

### LearningSession
```dart
{
  sessionId: String,
  startTime: DateTime,
  endTime: DateTime?,
  characterClass: String,
  characterIds: List<int>,
  questionsAnswered: int,
  correctAnswers: int
}
```

## Planned Features (Sprint 2+)

### Recognition Drill Mode
- Multiple choice character recognition
- Smart distractor selection (visually similar characters)
- Immediate feedback with animations
- Progressive difficulty

### Spaced Repetition
- Characters needing review highlighted
- Review recommendations based on accuracy and time
- Adaptive learning paths

### Speed Challenge
- Timed recognition tests
- Increasing difficulty levels
- Performance tracking

### Analytics
- Learning curve visualization
- Session history
- Performance trends by character class

## Usage Tips

### For Learners
1. Start with consonants (most fundamental)
2. Practice in short sessions (5-10 minutes)
3. Review characters that fall below 70% accuracy
4. Use audio playback repeatedly to internalize sounds

### For Developers
- Character data in `assets/data/characters.json`
- Audio files in `assets/audio/*.caf`
- Extend `CharacterGroupingService` for custom filtering
- Add new practice modes by creating new pages with same data flow

## Accessibility
- Large, readable character display
- Audio support for all characters
- Clear visual feedback
- Simple navigation controls
- Color-coded categories

## Performance Notes
- Lazy loading recommended for large character sets
- Audio files preloaded in background
- Progress calculations cached during sessions
- Efficient JSON serialization for quick data access

## Contributing
When adding features:
1. Follow existing Cubit pattern for state management
2. Use `CharacterGroupingService` for character filtering
3. Update `AlphabetPracticeRepository` for new data storage needs
4. Ensure JSON serialization for new models
5. Add visual feedback for user actions
6. Test with full character set (45+ characters)

## Dependencies
- `flutter_bloc`: State management
- `shared_preferences`: Local data storage
- `audioplayers`: Audio playback
- `json_annotation` / `json_serializable`: Data serialization
- `equatable`: Value equality
