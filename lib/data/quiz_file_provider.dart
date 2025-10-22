import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> loadJsonFromFile(String filePath) async {
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
