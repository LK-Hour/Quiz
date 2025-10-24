import 'domain/quiz.dart';
import 'ui/quiz_console.dart';
import 'data/quiz_file_provider.dart';

/// Main entry point - now uses proper layered architecture
/// Data layer handles all file operations, not main.dart
void main() async {
  // Load questions from data layer
  final questions = await loadQuestions();

  if (questions.isEmpty) {
    print('No questions found. Please check lib/data/questions.json');
    return;
  }

  // Save questions back to JSON to persist generated IDs
  // This ensures question IDs remain stable across app restarts
  await saveQuestions(questions);

  // Load existing players from data layer
  final players = await loadPlayers();

  // Create quiz with questions only (answers are stored in players)
  Quiz quiz = Quiz(questions: questions);

  // Start the quiz console with existing players
  QuizConsole console = QuizConsole(
    quiz: quiz,
    existingPlayers: players,
  );

  await console.startQuiz();
}
