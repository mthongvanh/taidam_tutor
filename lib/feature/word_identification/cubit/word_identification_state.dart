import 'package:equatable/equatable.dart';
import 'package:taidam_tutor/core/services/word_identification_service.dart';

enum WordIdentificationMode {
  beginner,
  intermediate,
  advanced,
}

extension WordIdentificationModeX on WordIdentificationMode {
  String get label => switch (this) {
        WordIdentificationMode.beginner => 'Beginner',
        WordIdentificationMode.intermediate => 'Intermediate',
        WordIdentificationMode.advanced => 'Advanced',
      };

  String get description => switch (this) {
        WordIdentificationMode.beginner =>
          'Shows romanization and fewer answer choices.',
        WordIdentificationMode.intermediate =>
          'Standard difficulty with four sound options.',
        WordIdentificationMode.advanced =>
          'Hide romanization and add an extra distractor.',
      };
}

class WordIdentificationState extends Equatable {
  const WordIdentificationState({
    this.isLoading = false,
    this.errorMessage,
    this.mode = WordIdentificationMode.beginner,
    this.challenge,
    this.currentQuestionIndex = 0,
    this.selectedOptionIndex,
    this.isSelectionCorrect,
    this.totalAnswered = 0,
    this.totalCorrect = 0,
  });

  final bool isLoading;
  final String? errorMessage;
  final WordIdentificationMode mode;
  final WordIdentificationChallenge? challenge;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool? isSelectionCorrect;
  final int totalAnswered;
  final int totalCorrect;

  WordQuestion? get currentQuestion {
    if (challenge == null) return null;
    if (currentQuestionIndex < 0 ||
        currentQuestionIndex >= challenge!.questions.length) {
      return null;
    }
    return challenge!.questions[currentQuestionIndex];
  }

  int get totalQuestions => challenge?.questions.length ?? 0;

  WordIdentificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    WordIdentificationMode? mode,
    WordIdentificationChallenge? challenge,
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    bool setSelectedOption = false,
    bool? isSelectionCorrect,
    bool setSelectionCorrect = false,
    int? totalAnswered,
    int? totalCorrect,
  }) {
    return WordIdentificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
      challenge: challenge ?? this.challenge,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionIndex:
          setSelectedOption ? selectedOptionIndex : this.selectedOptionIndex,
      isSelectionCorrect:
          setSelectionCorrect ? isSelectionCorrect : this.isSelectionCorrect,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      totalCorrect: totalCorrect ?? this.totalCorrect,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        mode,
        challenge,
        currentQuestionIndex,
        selectedOptionIndex,
        isSelectionCorrect,
        totalAnswered,
        totalCorrect,
      ];
}
