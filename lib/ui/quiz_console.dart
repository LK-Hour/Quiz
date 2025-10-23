import 'dart:io';

import '../domain/quiz.dart';

class QuizConsole {
  Quiz quiz;
  List<Player> players = [];
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
          Answer answer =
              Answer(questionId: question.id, answerChoice: userInput);
          quiz.addAnswer(answer);
        } else {
          print('No answer entered. Skipping question.');
        }

        print('');
      }

      int score = quiz.getScoreInPercentage();
      int point = quiz.getTotalPoint();
      print('${name.toUpperCase()}, your score: $score % correct');
      print('${name.toUpperCase()}, your score in points: $point');
      name = name.toUpperCase();

      // Copy the answers before clearing for next player
      List<Answer> playerAnswers = List.from(quiz.answers);

      int playerIndex =
          players.indexWhere((p) => p.name.toUpperCase() == name.toUpperCase());

      //overrid existing player
      if (playerIndex != -1) {
        players[playerIndex] = Player(
          name: name,
          totalScore: point,
          answers: playerAnswers,
        );
      } else {
        //add new player
        Player player = Player(
          name: name,
          totalScore: point,
          answers: playerAnswers,
        );
        players.add(player);
      }

      players.forEach((p) => print(p));
    }
    print('--- Quiz Finished ---');
  }
}
