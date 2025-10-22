import 'dart:io';

import '../domain/quiz.dart';

class QuizConsole {
  Quiz quiz;
  Map<String, int> player = {};
  String name = 'Start';

  QuizConsole({required this.quiz});

  void startQuiz() {
    print('--- Welcome to the Quiz ---\n');

    while (name != '') {
      stdout.write('Your name: ');
      name = stdin.readLineSync() ?? '';
      if (name == '') {
        break;
      }
      ;
      quiz.answers.clear();
      for (var question in quiz.questions) {
        print('Question: ${question.title} - (${question.point} Points)');
        print('Choices: ${question.choices}');
        stdout.write('Your answer: ');
        String? userInput = stdin.readLineSync();

        // Check for null input
        if (userInput != null && userInput.isNotEmpty) {
          Answer answer = Answer(question: question, answerChoice: userInput);
          quiz.addAnswer(answer);
        } else {
          print('No answer entered. Skipping question.');
        }

        print('');
      }

      int score = quiz.getScoreInPercentage();
      int point = quiz.getTotalPoint();
      print('$name, your score: $score % correct');
      print('$name, your score in points: $point');
      name = name.toUpperCase();
      player[name] = point;
      player.forEach((name, score) => print("Player: $name     Score: $score"));
    }
    print('--- Quiz Finished ---');
  }
}
