import 'dart:io';
import '../domain/quiz.dart';
import '../data/quiz_file_provider.dart';

/// UI Layer: Handles console interaction with users
/// Now properly separates concerns - Quiz provides questions, Player stores answers
class QuizConsole {
  final Quiz quiz;
  List<Player> players = [];

  QuizConsole({required this.quiz, List<Player>? existingPlayers}) {
    players = existingPlayers ?? [];
  }

  Future<void> startQuiz() async {
    print('--- Welcome to the Quiz ---\n');

    if (players.isNotEmpty) {
      print('Previous players:');
      players.forEach((p) => print('  ${p}'));
      print('');
    }

    String name = 'Start';
    while (name.isNotEmpty) {
      stdout.write('Your name (or press Enter to quit): ');
      name = stdin.readLineSync()?.trim() ?? '';

      if (name.isEmpty) {
        break;
      }

      // Each player stores their own answers
      List<Answer> playerAnswers = [];

      // Present each question
      for (var question in quiz.questions) {
        print('\nQuestion: ${question.title} - (${question.point} Points)');
        print('Choices: ${question.choices}');
        stdout.write('Your answer: ');
        String? userInput = stdin.readLineSync()?.trim();

        // Store answer with question ID (keeps question details private)
        if (userInput != null && userInput.isNotEmpty) {
          Answer answer = Answer(
            questionId: question.id,
            answerChoice: userInput,
          );
          playerAnswers.add(answer);
        } else {
          print('No answer entered. Skipping question.');
        }
      }

      // Calculate score based on player's answers
      int score = quiz.getScoreInPercentage(playerAnswers);
      int points = quiz.getTotalPoints(playerAnswers);

      print('\n${name.toUpperCase()}, your score: $score% correct');
      print('${name.toUpperCase()}, your total points: $points');

      name = name.toUpperCase();

      // Check if player already exists (case-insensitive)
      int playerIndex = players.indexWhere((p) => p.name.toUpperCase() == name);

      if (playerIndex != -1) {
        // Override existing player
        players[playerIndex] = Player(
          id: players[playerIndex].id, // Keep same ID
          name: name,
          totalScore: points,
          answers: playerAnswers,
        );
        print('(Updated existing player record)');
      } else {
        // Add new player
        Player player = Player(
          name: name,
          totalScore: points,
          answers: playerAnswers,
        );
        players.add(player);
        print('(New player record created)');
      }

      // Show all players
      print('\n--- Leaderboard ---');
      players.forEach((p) => print(p));
      print('');
    }

    // Save all players to JSON file
    await savePlayers(players);
    print('\n--- Quiz Finished ---');
  }
}
