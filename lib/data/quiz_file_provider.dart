import 'dart:convert';
import 'dart:io';
import '../domain/quiz.dart';

/// Data layer: handles all file operations for questions and players
/// This follows proper layered architecture - main.dart should not handle raw data

const String questionsFilePath = 'lib/data/questions.json';
const String playersFilePath = 'lib/data/players.json';

/// Load questions from JSON file
Future<List<Question>> loadQuestions() async {
  try {
    final data = await _loadJsonFromFile(questionsFilePath);
    final questions = ((data['questions'] as List<dynamic>?) ?? [])
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
    return questions;
  } catch (e) {
    print('Error loading questions: $e');
    return [];
  }
}

/// Load players from JSON file
Future<List<Player>> loadPlayers() async {
  try {
    final file = File(playersFilePath);

    // Create empty players file if it doesn't exist
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode({'players': []}));
      return [];
    }

    final data = await _loadJsonFromFile(playersFilePath);
    final players = ((data['players'] as List<dynamic>?) ?? [])
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();
    return players;
  } catch (e) {
    print('Error loading players: $e');
    return [];
  }
}

/// Save players to JSON file
Future<void> savePlayers(List<Player> players) async {
  try {
    final file = File(playersFilePath);
    await file.create(recursive: true);

    final data = {
      'players': players.map((p) => p.toJson()).toList(),
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);
    print('✓ Players saved successfully');
  } catch (e) {
    print('Error saving players: $e');
  }
}

/// Save questions to JSON file (with generated IDs)
/// This ensures IDs persist across app restarts
Future<void> saveQuestions(List<Question> questions) async {
  try {
    final file = File(questionsFilePath);

    final data = {
      'questions': questions.map((q) => q.toJson()).toList(),
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);
    print('✓ Questions with IDs saved successfully');
  } catch (e) {
    print('Error saving questions: $e');
  }
}

/// Private helper to load JSON from file
Future<Map<String, dynamic>> _loadJsonFromFile(String filePath) async {
  try {
    File file = File(filePath);
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return jsonData;
  } catch (e) {
    print('Error reading JSON file: $e');
    return {};
  }
}
