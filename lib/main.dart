import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taidam_tutor/core/data/characters/models/character.dart';
import 'package:taidam_tutor/core/di/dependency_manager.dart';
import 'package:taidam_tutor/feature/alphabet_practice/alphabet_practice_page.dart';
import 'package:taidam_tutor/feature/character_list/character_list.dart';
import 'package:taidam_tutor/feature/flashcard/flashcard_practice_page.dart';
import 'package:taidam_tutor/feature/letter_search/letter_search.dart';
import 'package:taidam_tutor/feature/quiz/quiz_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  DependencyManager().registerDependencies();
  final darkText = ThemeData.dark().textTheme;
  runApp(
    MaterialApp(
      title: 'Tai Dam Tutor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme().copyWith(
          bodyLarge: GoogleFonts.latoTextTheme().bodyLarge,
          bodyMedium: GoogleFonts.latoTextTheme().bodyMedium,
          bodySmall: GoogleFonts.latoTextTheme().bodySmall,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black12,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme(darkText).copyWith(
          bodyLarge: GoogleFonts.latoTextTheme(darkText).bodyLarge,
          bodyMedium: GoogleFonts.latoTextTheme(darkText).bodyMedium,
          bodySmall: GoogleFonts.latoTextTheme(darkText).bodySmall,
        ),
      ),
      home: BlocProvider<AppCubit>(
        create: (context) => AppCubit(),
        child: const App(),
      ),
    ),
  );
}

typedef InitGameParams = ({
  Character targetLetter,
  List<Character> allowedLetters
});

class AppCubit extends Cubit<int> {
  AppCubit() : super(0) {
    debugPrint('AppCubit initialized');
    init();
  }

  void init() {
    emit(0);
  }

  void reload() {
    emit(0);
    init();
  }

  void onItemTapped(int index) {
    emit(index);
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, int>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? LinearGradient(
                      colors: [
                        const Color.fromARGB(80, 42, 84, 112),
                        const Color.fromARGB(80, 66, 65, 119),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        const Color.fromARGB(80, 42, 84, 112),
                        const Color.fromARGB(80, 66, 65, 119),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: Center(
              child: _widgetOptions.elementAt(state),
            ),
          ),
          resizeToAvoidBottomInset: true,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardPracticePage(),
                ),
              );
            },
            icon: const Icon(Icons.style),
            label: const Text('Practice Flashcards'),
            tooltip: 'Practice with flashcards',
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt),
                label: 'Characters',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Finder',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz),
                label: 'Quiz',
              ),
            ],
            currentIndex: state,
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: context.read<AppCubit>().onItemTapped,
            showUnselectedLabels: true,
          ),
        );
      },
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    CharacterListPage(),
    const AlphabetPracticePage(),
    LetterSearchGame(),
    QuizPage(),
  ];
}
