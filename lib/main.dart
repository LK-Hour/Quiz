import 'domain/quiz.dart';
import 'ui/quiz_console.dart';
import 'data/quiz_file_provider.dart';

void main() async {
  final data = await loadJsonFromFile('lib/data/questions.json');
  final questions = ((data['questions'] as List<dynamic>?) ?? const [])
      .map((quest) => Question.fromJson(quest as Map<String, dynamic>))
      .toList();

  if (questions.isEmpty) {
    print('No questions found in lib/data/questions.json');
    return;
  }
  Quiz quiz = Quiz(questions: questions);
  QuizConsole console = QuizConsole(quiz: quiz);
  console.startQuiz();
}
