import 'package:quiz/data/quiz_file_provider.dart';

void main() async {
  print('Loading players from lib/data/players.json...');
  final players = await loadPlayers();

  print('\nFound ${players.length} players:');
  for (final player in players) {
    print('\n${player.name}:');
    print('Total Score: ${player.totalScore}');
    print('Answers: ${player.answers.length}');
    for (final answer in player.answers) {
      print(
          '- Question ${answer.questionId}: answered "${answer.answerChoice}"');
    }
  }

  print('\nSaving players to lib/data/players_copy.json...');
  await savePlayersToFile(players, 'lib/data/players_copy.json');

  print('\nReloading from copy...');
  final reloaded = await loadPlayersFromFile('lib/data/players_copy.json');
  print('Reloaded ${reloaded.length} players successfully!');
}
