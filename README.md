# Tai Dam Tutor

Tai Dam Tutor is a Flutter learning companion that teaches the Tai Dam script and pronunciation through offline lesson data, flashcards, games, and quizzes. The app blends clean UI, curated audio, and guided practice paths so learners can progress without an internet connection.

![Tai Dam Tutor preview banner](https://placehold.co/1200x320?text=Tai+Dam+Tutor)

---

## 🚀 Feature Highlights

- **Alphabet practice** – Guided drills that pair glyph tracing with audio playback, spaced repetition tracking, and a progress dashboard backed by an in-app "Understanding Your Progress" guide.
- **Character browser** – Filterable list of consonants, vowels, combos, and special glyphs with tone/position metadata.
- **Flashcards** – Swipe-based decks that surface pronunciation hints, regex links to related characters, and previews of common words.
- **Letter search game** – Quick-play minigame that challenges users to spot the right glyph among distractors.
- **Quizzes** – Multiple-choice assessments that mix listening comprehension with recognition prompts.
- **Consistent quiz feedback** – Shared quiz feedback banner standardizes the correct/incorrect callouts across alphabet drills, reading lessons, and future quiz surfaces.
- **Reading lessons** – Curated lesson plans that stitch characters into real Tai Dam words and phrases.
- **More hub** – Central place for settings, reference material, and future community resources.

All experiences are backed by offline JSON datasets plus `.caf` audio samples, so the entire curriculum travels with the app.

---

## 🧱 Architecture at a Glance

- **Feature-first layout** (`lib/feature/*`) keeps pages, widgets, and Cubits scoped to each experience.
- **BLoC/Cubit state management** provides deterministic UI flows without full BLoC boilerplate.
- **GetIt dependency injection** (see `lib/core/di/dependency_manager.dart`) wires repositories, services, and shared utilities.
- **Local JSON repositories** in `lib/core/data/*` load character, flashcard, quiz, and practice content via asset bundles.
- **Business-logic services** (e.g., `CharacterGroupingService`) encapsulate domain-specific rules for sorting/grouping glyphs.
- **Shared widgets & extensions** under `lib/widgets` and `lib/utils/extensions` enforce typography, spacing, and card behavior (e.g., `QuizFeedbackBanner`, `TaiCard`).

```
lib/
├─ core/
│  ├─ data/                # JSON models, repositories, local data sources
│  ├─ di/                  # Dependency manager (GetIt)
│  └─ services/           # Business logic utilities
├─ feature/
│  ├─ alphabet_practice/
│  ├─ character_list/
│  ├─ flashcard/
│  ├─ letter_search/
│  ├─ quiz/
│  └─ reading_lesson/
├─ utils/                 # Extensions & constants (e.g., spacing enum)
└─ widgets/               # Shared UI components
```

---

## 🛠 Tech Stack

- **Flutter 3.6+** with Material 3 theming and custom gradients
- **State**: `flutter_bloc` (Cubit) + `equatable`
- **DI**: `get_it`
- **Serialization**: `json_annotation`/`json_serializable` + `build_runner`
- **Storage**: `sqflite`, `shared_preferences` for practice progress
- **Media**: `audioplayers` (preferred) and `just_audio` for legacy playback
- **Fonts**: Tai Heritage Pro embedded in `assets/fonts`

---

## 📦 Assets & Content

| Type   | Location                | Notes |
|--------|-------------------------|-------|
| Audio  | `assets/audio/`         | `.caf` clips for vowels, consonants, words |
| Data   | `assets/data/`          | JSON definitions, flashcard decks, quiz pools |
| Images | `assets/images/{svg,png}/` | Icons, illustrations for lessons |
| Fonts  | `assets/fonts/`         | Tai Heritage Pro (bold/regular) |

When you update JSON models, also provide matching audio/image references. Asset folders are already registered in `pubspec.yaml`.

---

## 🧑‍💻 Getting Started

### Prerequisites

- Flutter SDK `3.6.2` (or later within 3.x)
- Dart SDK bundled with Flutter
- Xcode / Android Studio with simulators or devices available

### Setup

```bash
git clone https://github.com/mthongvanh/taidamTutor.git
cd taidam_tutor
flutter pub get
```

To refresh generated model code after editing any `@JsonSerializable` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the app

```bash
flutter run
```

By default the app boots into the four-tab experience (Alphabet, Reading, Characters, More) driven by `AppCubit`.

---

## ✅ Testing & Quality

- Unit tests live under `test/` (currently focused on core models, with more coming soon).
- Run the whole suite via:

```bash
flutter test
```

- Lints follow `flutter_lints` rules configured in `analysis_options.yaml`. Most IDEs surface issues automatically.

---

## 🗺️ Working with Data & Services

- Repositories follow **Repository → LocalDataSource → JSON** chain (`init()` guards prevent duplicate loads).
- `CharacterClass` is an enum (`lib/core/data/characters/models/character_class.dart`)—use it instead of raw strings when adding logic.
- Alphabet practice progress is persisted through `AlphabetPracticeRepository` + `shared_preferences`.
- Audio playback should go through `audioplayers` with `AssetSource('audio/<file>.caf')`.

---

## 🤝 Contributing

1. Fork & branch from `main`.
2. Keep features scoped (follow feature-first folder pattern).
3. Add/update tests whenever user-facing behavior changes.
4. Run `flutter format .` (or your IDE’s formatter) plus `flutter test` before opening a PR.
5. Include screenshots or screen recordings if your change affects UI/UX.

Bug reports and feature ideas are welcome in GitHub issues—please include device, OS, and reproduction steps.

---

## 📚 Useful Scripts & Docs

- `scripts/add_romanization_hints.py` – generates romanization hints for vocabulary datasets.
- `SPRINT*_SUMMARY.md` – sprint notes/changelogs from earlier development cycles.
- `support/` – supplemental CSV/JSON sources that feed into the curated `assets/data` files.

---

## 📄 License

The project currently does not specify a license. If you plan to distribute builds publicly, coordinate with the maintainers to add the appropriate license text.

---

### Questions?

Open an issue or reach out via the repository discussions tab. Happy learning!
