import 'package:uuid/uuid.dart';

class Question {
  final String id;
  final String title;
  final List<String> choices;
  final String goodChoice;
  final int point;

  Question(
      {String? id,
      required this.title,
      required this.choices,
      required this.goodChoice,
      required this.point})
      : id = id ?? Uuid().v4();

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String?,
      title: json['title'] as String,
      choices: List<String>.from(json['choices'] as List<dynamic>),
      goodChoice: json['goodChoice'] as String,
      point: (json['point'] as num).toInt(),
    );
  }
}

class Answer {
  final String questionId;
  final String answerChoice;

  Answer({required this.questionId, required this.answerChoice});

  bool isGood(Question question) {
    return answerChoice.toLowerCase() == question.goodChoice.toLowerCase();
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'answerChoice': answerChoice,
      };

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] as String,
      answerChoice: json['answerChoice'] as String,
    );
  }
}

class Quiz {
  List<Question> questions;
  List<Answer> answers = [];

  Question? getQuestionById(String id) {
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  Quiz({required this.questions});

  void addAnswer(Answer answer) {
    answers.add(answer);
  }

  int getScoreInPercentage() {
    int totalScore = 0;
    for (Answer answer in answers) {
      final question = getQuestionById(answer.questionId);
      if (question != null && answer.isGood(question)) {
        totalScore++;
      }
    }
    return ((totalScore / questions.length) * 100).toInt();
  }

  int getTotalPoint() {
    int totalPoint = 0;
    for (Answer answer in answers) {
      final question = getQuestionById(answer.questionId);
      if (question != null && answer.isGood(question)) {
        totalPoint += question.point;
      }
    }
    return totalPoint;
  }
}

class Player {
  final String name;
  final int totalScore;
  final List<Answer> answers;

  Player({
    required this.name,
    required this.totalScore,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'totalScore': totalScore,
        'answers': answers.map((a) => a.toJson()).toList(),
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      answers: ((json['answers'] as List<dynamic>?) ?? const [])
          .map((a) => Answer.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => 'Player: $name     Score: $totalScore';
}
