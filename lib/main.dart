import 'domain/quiz.dart';
import 'ui/quiz_console.dart';
import 'data/quiz_file_provider.dart';

void main() async {
  final questions = await loadQuestions();

  if (questions.isEmpty) {
    print('No questions found in lib/data/questions.json');
    return;
  }

  final quiz = Quiz(questions: questions);
  final console = QuizConsole(quiz: quiz);
  console.startQuiz();
}
