import 'package:uuid/uuid.dart';

class Question {
  final String id;
  final String title;
  final List<String> choices;
  final String goodChoice;
  final int point;

  Question({
    String? id,
    required this.title,
    required this.choices,
    required this.goodChoice,
    required this.point,
  }) : id = id ?? Uuid().v4();

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String?,
      title: json['title'] as String,
      choices: List<String>.from(json['choices'] as List<dynamic>),
      goodChoice: json['goodChoice'] as String,
      point: (json['point'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'choices': choices,
      'goodChoice': goodChoice,
      'point': point,
    };
  }
}

/// Answer now only stores question ID and the chosen answer
/// This keeps question details secret and follows better separation of concerns
class Answer {
  final String questionId;
  final String answerChoice;

  Answer({
    required this.questionId,
    required this.answerChoice,
  });

  /// Check if answer is correct by comparing with the question
  bool isCorrect(Question question) {
    return answerChoice.toLowerCase() == question.goodChoice.toLowerCase();
  }

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] as String,
      answerChoice: json['answerChoice'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answerChoice': answerChoice,
    };
  }
}

/// Quiz now only manages questions, not answers
/// Each Player owns their own answers
class Quiz {
  final List<Question> questions;

  Quiz({required this.questions});

  /// Calculate score percentage for a player based on their answers
  int getScoreInPercentage(List<Answer> playerAnswers) {
    int correctCount = 0;
    for (Answer answer in playerAnswers) {
      Question? question = getQuestionById(answer.questionId);
      if (question != null && answer.isCorrect(question)) {
        correctCount++;
      }
    }
    return questions.isEmpty
        ? 0
        : ((correctCount / questions.length) * 100).toInt();
  }

  /// Calculate total points for a player based on their answers
  int getTotalPoints(List<Answer> playerAnswers) {
    int totalPoints = 0;
    for (Answer answer in playerAnswers) {
      Question? question = getQuestionById(answer.questionId);
      if (question != null && answer.isCorrect(question)) {
        totalPoints += question.point;
      }
    }
    return totalPoints;
  }

  /// Get a question by its ID
  Question? getQuestionById(String id) {
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Player stores their own answers and score
class Player {
  final String id;
  final String name;
  final int totalScore;
  final List<Answer> answers;

  Player({
    String? id,
    required this.name,
    required this.totalScore,
    required this.answers,
  }) : id = id ?? Uuid().v4();

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String?,
      name: json['name'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      answers: ((json['answers'] as List<dynamic>?) ?? [])
          .map((a) => Answer.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalScore': totalScore,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Player: $name     Score: $totalScore';
}
