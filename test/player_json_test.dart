import 'package:test/test.dart';
import 'package:quiz/domain/quiz.dart';
import 'package:quiz/data/quiz_file_provider.dart';

void main() {
  test('Player JSON round-trip test', () async {
    // Load initial players
    final players = await loadPlayers();
    expect(players, isNotEmpty);
    expect(players.length, 2);

    // Verify first player
    final alice = players[0];
    expect(alice.name, 'Alice');
    expect(alice.totalScore, 85);
    expect(alice.answers.length, 3);

    // Verify second player
    final bob = players[1];
    expect(bob.name, 'Bob');
    expect(bob.totalScore, 70);
    expect(bob.answers.length, 2);

    // Test saving and reloading
    await savePlayersToFile(players, 'lib/data/players_copy.json');
    final reloadedPlayers =
        await loadPlayersFromFile('lib/data/players_copy.json');

    // Verify reloaded data matches
    expect(reloadedPlayers.length, players.length);
    expect(reloadedPlayers[0].name, players[0].name);
    expect(reloadedPlayers[0].totalScore, players[0].totalScore);
    expect(reloadedPlayers[0].answers.length, players[0].answers.length);
  });
}
