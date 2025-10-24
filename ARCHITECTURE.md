# Architecture Documentation

## 🎯 Overview

This project has been refactored to follow **Clean Architecture** principles with proper layered separation. The new design makes the code more maintainable, testable, and secure.

## 🔄 Major Changes

### 1. **Answer Class Redesign** 
**Before:**
```dart
class Answer {
  final Question question;  // Stored full question object
  final String answerChoice;
  
  bool isGood() {
    return answerChoice.toLowerCase() == question.goodChoice.toLowerCase();
  }
}
```

**After:**
```dart
class Answer {
  final String questionId;  // Only stores question ID
  final String answerChoice;
  
  bool isCorrect(Question question) {
    return answerChoice.toLowerCase() == question.goodChoice.toLowerCase();
  }
}
```

**Benefits:**
- ✅ **Security**: Question details remain private (only ID is stored)
- ✅ **Cleaner design**: No circular dependencies
- ✅ **Serialization**: Easy to save/load from JSON
- ✅ **Flexibility**: Can validate against any Question by passing it as parameter

---

### 2. **Quiz Class Simplification**
**Before:**
```dart
class Quiz {
  List<Question> questions;
  List<Answer> answers = [];  // Quiz owned all answers
  
  void addAnswer(Answer answer) {
    this.answers.add(answer);
  }
  
  int getScoreInPercentage() { /* ... */ }
  int getTotalPoint() { /* ... */ }
}
```

**After:**
```dart
class Quiz {
  final List<Question> questions;  // Only manages questions
  
  int getScoreInPercentage(List<Answer> playerAnswers) { /* ... */ }
  int getTotalPoints(List<Answer> playerAnswers) { /* ... */ }
  Question? getQuestionById(String id) { /* ... */ }
}
```

**Benefits:**
- ✅ **Single Responsibility**: Quiz only manages questions, not player data
- ✅ **Stateless**: No mutable state, easier to reason about
- ✅ **Flexible**: Can calculate scores for any player's answers
- ✅ **Thread-safe**: No shared mutable state

---

### 3. **Player Owns Their Answers**
**Before:**
- Answers stored globally in Quiz
- Had to manually track which answers belong to which player
- Risk of mixing up player data

**After:**
```dart
class Player {
  final String id;
  final String name;
  final int totalScore;
  final List<Answer> answers;  // Each player owns their answers
  
  Player({String? id, ...}) : id = id ?? Uuid().v4();
  
  factory Player.fromJson(Map<String, dynamic> json) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
}
```

**Benefits:**
- ✅ **Clear ownership**: Each player has their own answer history
- ✅ **Persistence**: Easy to save/load player records
- ✅ **Auditing**: Can review what each player answered
- ✅ **Multi-player friendly**: No risk of data contamination

---

### 4. **Data Layer Abstraction**
**Before:**
```dart
// In main.dart - mixing concerns
void main() async {
  final data = await loadJsonFromFile('lib/data/questions.json');
  final questions = ((data['questions'] as List<dynamic>?) ?? const [])
      .map((q) => Question.fromJson(q as Map<String, dynamic>))
      .toList();
  // ...
}
```

**After:**
```dart
// quiz_file_provider.dart - centralized data layer
Future<List<Question>> loadQuestions() async { /* ... */ }
Future<List<Player>> loadPlayers() async { /* ... */ }
Future<void> savePlayers(List<Player> players) async { /* ... */ }

// main.dart - clean and simple
void main() async {
  final questions = await loadQuestions();
  final players = await loadPlayers();
  // ...
}
```

**Benefits:**
- ✅ **Separation of Concerns**: UI/Domain code never touches file I/O
- ✅ **Testability**: Easy to mock data layer
- ✅ **Maintainability**: Change storage without touching business logic
- ✅ **Consistency**: All file operations in one place

---

### 5. **Player Persistence**
**New Feature:**
- Player records automatically saved to `lib/data/players.json`
- Includes: id, name, totalScore, and all answers
- Previous players loaded on app start
- Duplicate names (case-insensitive) update existing records

**Example `players.json`:**
```json
{
  "players": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "ALICE",
      "totalScore": 60,
      "answers": [
        {
          "questionId": "q1-uuid",
          "answerChoice": "Paris"
        }
      ]
    }
  ]
}
```

---

## 📐 Architecture Layers

### 1. Data Layer (`lib/data/`)
**Responsibility**: Handle all I/O operations

**Files:**
- `quiz_file_provider.dart`: File operations for questions and players
- `questions.json`: Input data
- `players.json`: Output data (auto-generated)

**Key Functions:**
```dart
Future<List<Question>> loadQuestions()
Future<List<Player>> loadPlayers()
Future<void> savePlayers(List<Player> players)
```

---

### 2. Domain Layer (`lib/domain/`)
**Responsibility**: Business logic and models

**Files:**
- `quiz.dart`: All domain models

**Classes:**
- `Question`: Quiz question with choices and correct answer
- `Answer`: Links question ID with user's choice
- `Quiz`: Manages questions and scoring logic
- `Player`: User record with answers and score

**Key Methods:**
```dart
// Quiz
int getScoreInPercentage(List<Answer> playerAnswers)
int getTotalPoints(List<Answer> playerAnswers)
Question? getQuestionById(String id)

// Answer
bool isCorrect(Question question)
```

---

### 3. UI Layer (`lib/ui/`)
**Responsibility**: User interaction

**Files:**
- `quiz_console.dart`: Console interface

**Key Features:**
- Loads existing players
- Presents questions
- Collects answers
- Shows results
- Saves player records

---

## 🔒 Security Benefits

### Before: Full Question Exposure
```dart
class Answer {
  final Question question;  // Contains all question data
  final String answerChoice;
}
```
**Risk**: Anyone with access to Answer objects could see:
- The correct answer (`question.goodChoice`)
- Question title
- All choices
- Points value

### After: Only Question ID
```dart
class Answer {
  final String questionId;  // Only an identifier
  final String answerChoice;
}
```
**Benefit**: Answer objects can be shared/stored without revealing question details. To validate, you need access to the Question object separately.

---

## 🧪 Testing

All tests updated to reflect new architecture. **15 tests passing**:

### Test Coverage:
- ✅ Question UUID generation
- ✅ Answer with question ID only
- ✅ Case-insensitive answer validation
- ✅ Quiz percentage scoring (100%, 50%, 0%, decimal truncation)
- ✅ Quiz point totals
- ✅ Data loading from JSON
- ✅ Player serialization (toJson/fromJson)

---

## 🚀 How It Works Now

### Flow Diagram:
```
main.dart
  ↓
  ├─→ loadQuestions() → [Question, Question, ...]
  ├─→ loadPlayers()   → [Player, Player, ...]
  ↓
Quiz(questions)
  ↓
QuizConsole(quiz, existingPlayers)
  ↓
  ├─→ Present each Question
  ├─→ Collect Answer (questionId + answerChoice)
  ├─→ Store in Player.answers
  ├─→ Calculate score via quiz.getTotalPoints(player.answers)
  ↓
savePlayers(allPlayers)
```

### Key Interactions:

1. **App Start:**
   - Load questions from JSON → List\<Question\>
   - Load players from JSON → List\<Player\>
   - Create Quiz with questions

2. **During Quiz:**
   - For each question, create Answer(questionId, userInput)
   - Add Answer to player's answer list
   - No data stored in Quiz itself

3. **After Quiz:**
   - Calculate score: `quiz.getTotalPoints(player.answers)`
   - Create/Update Player with answers and score
   - Save all players to JSON

4. **Validation:**
   - Answer has only questionId
   - To check if correct: `answer.isCorrect(question)`
   - Quiz looks up Question by ID when calculating scores

---

## 📊 Comparison

| Aspect | Before | After |
|--------|--------|-------|
| **Answer storage** | Full Question object | Question ID only |
| **Quiz state** | Mutable (answers list) | Immutable (questions only) |
| **Player answers** | Scattered in Quiz | Owned by Player |
| **Data loading** | In main.dart | In quiz_file_provider.dart |
| **Persistence** | None | Auto-save to players.json |
| **Security** | Answers expose questions | Answers are just IDs |
| **Testing** | 13 tests | 15 tests |

---

## 🎓 Best Practices Followed

1. ✅ **Separation of Concerns**: Each layer has clear responsibility
2. ✅ **Single Responsibility Principle**: Each class does one thing well
3. ✅ **Dependency Inversion**: High-level code doesn't depend on low-level I/O
4. ✅ **Immutability**: Domain models use `final` fields
5. ✅ **Serialization**: All models have toJson/fromJson
6. ✅ **UUID Generation**: Auto-generated IDs for entities
7. ✅ **Case-Insensitive Comparison**: Robust answer checking
8. ✅ **Defensive Copying**: Player answers are properly isolated
9. ✅ **Error Handling**: Try-catch in data layer operations
10. ✅ **Documentation**: Comprehensive README and architecture docs

---

## 🔮 Future Enhancements

Potential improvements that build on this architecture:

1. **Database Backend**: Replace JSON files with SQLite/PostgreSQL
2. **REST API**: Add server layer for remote quiz hosting
3. **Authentication**: Add user login/registration
4. **Categories**: Organize questions by topic
5. **Difficulty Levels**: Easy/Medium/Hard questions
6. **Timed Quizzes**: Add countdown timers
7. **Leaderboard**: Global rankings
8. **Review Mode**: Let players review their past answers
9. **Statistics**: Track player performance over time
10. **Export**: Generate PDF reports of quiz results

All these features are easier to implement now thanks to the clean architecture!

---

## 📝 Migration Guide

If you have existing code using the old architecture:

### 1. Update Answer Creation
```dart
// OLD
Answer(question: questionObj, answerChoice: "Paris")

// NEW
Answer(questionId: questionObj.id, answerChoice: "Paris")
```

### 2. Update Answer Validation
```dart
// OLD
answer.isGood()

// NEW
answer.isCorrect(question)
```

### 3. Update Quiz Usage
```dart
// OLD
quiz.addAnswer(answer);
int score = quiz.getTotalPoint();

// NEW
player.answers.add(answer);
int score = quiz.getTotalPoints(player.answers);
```

### 4. Use Data Layer
```dart
// OLD
final data = await loadJsonFromFile('...');
final questions = data['questions'].map(...);

// NEW
final questions = await loadQuestions();
```

---

## ✅ Conclusion

This refactoring transforms the quiz app from a simple script into a well-architected application. The new design is:

- **More Secure**: Answers don't expose question details
- **More Maintainable**: Clear layer separation
- **More Testable**: Easy to mock and test components
- **More Scalable**: Ready for features like persistence, APIs, etc.
- **More Professional**: Follows industry best practices

The codebase is now ready for real-world use and easy to extend! 🚀
