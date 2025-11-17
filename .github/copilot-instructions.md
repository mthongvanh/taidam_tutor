# Tai Dam Tutor - AI Coding Agent Instructions

## Project Overview
Tai Dam Tutor is a Flutter language-learning app teaching the Tai Dam script through interactive features: character browsing, flashcards, letter search game, and quizzes. The app uses offline JSON data with associated audio/image assets for characters and vocabulary.

## Architecture

### Core Structure (Feature-First)
- **`lib/feature/`**: Feature modules (character_list, flashcard, letter_search, quiz, alphabet_practice)
  - Each feature follows: `feature_page.dart`, `cubit/`, `widgets/`
- **`lib/core/`**: Shared data layer, services, and dependency injection
  - `core/data/{characters,flashcards,alphabet_practice}/`: Repository → LocalDataSource → JSON models
  - `core/services/`: Business logic services (e.g., `CharacterGroupingService`)
  - `core/di/dependency_manager.dart`: GetIt singleton registration
- **`lib/widgets/`**: Shared UI components (error widgets, etc.)
- **`lib/utils/extensions/`**: Extension methods (text_ext.dart, card_ext.dart)

### State Management
Uses **BLoC pattern** (flutter_bloc) with Cubits exclusively:
- Main navigation: `AppCubit` in `main.dart` (manages bottom nav index)
- Feature Cubits: `CharacterListCubit`, `CharacterFlashcardsCubit`, `LetterSearchCubit`, `QuizCubit`, `AlphabetPracticeCubit`
- Pattern: Emit state objects (not primitives except AppCubit), use sealed/enum states when appropriate

### Data Flow
1. **Repositories** (`CharacterRepository`, `FlashcardRepository`, `AlphabetPracticeRepository`) 
   - Registered as singletons in `DependencyManager`
   - Retrieved via `dm.get<Repository>()`
2. **LocalDataSources** load JSON via `rootBundle.loadString('assets/data/*.json')`
   - Initialize once with `init()` guard (`_isInitialized` flag)
   - `AlphabetPracticeRepository` uses `shared_preferences` for progress tracking
3. **Services** provide business logic (e.g., `CharacterGroupingService`)
   - Located in `lib/core/services/`
   - Stateless utility classes for filtering, grouping, and transforming data
4. **Models** use `json_serializable` with `@JsonSerializable(explicitToJson: true)` and `Equatable`
   - Generated files: `*.g.dart` (never edit manually)
   - Run `dart run build_runner build` after model changes

## Key Conventions

### Asset Management
- **Audio**: `.caf` format in `assets/audio/`, played via `AudioPlayer().play(AssetSource('audio/filename.caf'))`
- **Images**: SVG/PNG in `assets/images/{svg,png}/`
- **Data**: JSON files in `assets/data/` (characters.json, flashcards.json, quiz_questions.json)
- **Fonts**: Tai Heritage Pro fonts in `assets/fonts/` for script display

### JSON Models
- Use `json_annotation` + `json_serializable` for all models
- Include `part 'model_name.g.dart';` directive
- Extend `Equatable` for value equality
- Examples: `Character`, `Flashcard`, `Hint`, `QuizQuestion`

### UI Patterns
- **Theming**: Uses Google Fonts (Bricolage Grotesque headlines, Lato body) with dark mode support
- **Gradients**: Custom gradient background in `main.dart` scaffold
- **Custom Extensions**: `TaiText.appBarTitle()` for consistent title styling
- **Navigation**: Simple `BottomNavigationBar` in `main.dart`, direct `Navigator.push()` for detail screens
- **Spacing**: Use `Spacing` enum from `lib/core/constants/spacing.dart` for consistent spacing:
  - `Spacing.xs` (4.0), `Spacing.s` (8.0), `Spacing.m` (16.0)
  - `Spacing.l` (32.0), `Spacing.xl` (64.0)
  - Example: `SizedBox(height: Spacing.m)`, `EdgeInsets.all(Spacing.s)`

### Code Generation
**Critical**: After changing models with `@JsonSerializable`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Development Workflow

### Running the App
```bash
flutter pub get
flutter run
```

### Testing
- Minimal test coverage currently (see `test/core/data/characters/models/character_test.dart`)
- Uses `flutter_test` for unit tests
- Test models with JSON serialization/deserialization and equality

### Common Tasks
- **Add new feature**: Create `lib/feature/feature_name/` with page, cubit/, widgets/
- **Add character/flashcard data**: Edit JSON in `assets/data/`, ensure matching audio files exist
- **New model**: Create with json_serializable, extend Equatable, run build_runner
- **Register dependency**: Add to `DependencyManager.registerDependencies()`
- **Add business logic service**: Create in `lib/core/services/` as stateless utility class

## Project-Specific Notes

### Tai Dam Script Handling
- `Character` model has `characterClass` (consonant, vowel, vowel-combo, special)
- `highLow` property for consonants (tone class), `prePost` for vowel positioning
- Flashcards link to characters via regex matching (see `Character.regEx`)
- Always consider the language rules when implementing features involving script representation which can be found in the `assets/data/language-rules.txt`

### Character Class Enum Migration
- `CharacterClass` lives in `lib/core/data/characters/models/character_class.dart` and must be used everywhere instead of raw strings (it exposes helper getters for titles/descriptions).
- `Character.characterClass` is an enum field; repositories/services/widgets should pass around `CharacterClass` keys (e.g., `Map<CharacterClass, List<Character>>`).
- Alphabet practice widgets/cubits are mid-migration—when you touch those areas, continue converting any remaining string-based logic to use the enum.
- After modifying enum or model annotations, re-run `dart run build_runner build --delete-conflicting-outputs` and fix downstream usages before committing.

### Audio Strategy
Both `audioplayers` and `just_audio` packages present—prefer `audioplayers` (used in flashcard/quiz):
```dart
final player = AudioPlayer();
player.play(AssetSource('audio/a1.caf'));
```

### Localization
No formal i18n yet. English UI with Tai Dam/Lao script display via custom fonts.

## Anti-Patterns to Avoid
- Don't edit `*.g.dart` files—always regenerate via build_runner
- Don't use BLoCs—this project uses Cubits only
- Don't import models without running build_runner if json_serializable annotations changed
- Don't register dependencies outside `DependencyManager`
- Don't create functions that returns widgets in build methods; use separate widget classes instead
- Don't hardcode strings; use or create constants in `lib/core/constants/` when possible
- Don't use magic numbers for spacing; use `Spacing` enum values instead (e.g., `Spacing.m` not `16.0`)
