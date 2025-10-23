import 'dart:convert';
import 'dart:io';

import '../domain/quiz.dart';

Future<List<Question>> loadQuestionsFromFile(String filePath) async {
  try {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final questions = ((jsonData['questions'] as List<dynamic>?) ?? const [])
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
    return questions;
  } catch (e) {
    print('Error reading or parsing JSON file "$filePath": $e');
    return <Question>[];
  }
}

Future<List<Question>> loadQuestions() async =>
    await loadQuestionsFromFile('lib/data/questions.json');

Future<void> savePlayersToFile(List<Player> players, String filePath) async {
  try {
    final file = File(filePath);
    final data = {
      'players': players.map((p) => p.toJson()).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  } catch (e) {
    print('Error saving players to file "$filePath": $e');
  }
}

Future<void> savePlayers(List<Player> players) async =>
    await savePlayersToFile(players, 'lib/data/players.json');

Future<List<Player>> loadPlayersFromFile(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return <Player>[];
    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final players = ((jsonData['players'] as List<dynamic>?) ?? const [])
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();
    return players;
  } catch (e) {
    print('Error reading or parsing players file "$filePath": $e');
    return <Player>[];
  }
}

Future<List<Player>> loadPlayers() async =>
    await loadPlayersFromFile('lib/data/players.json');
