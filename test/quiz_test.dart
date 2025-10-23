import 'package:quiz/domain/quiz.dart';
import 'package:quiz/data/quiz_file_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Question', () {
    //AI generated
    test('auto-generates a UUID id when not provided', () {
      final q = Question(
        title: 'Q',
        choices: ['a', 'b'],
        goodChoice: 'a',
        point: 5,
      );
      expect(q.id, isNotEmpty);
    });
  });

  group('Answer', () {
    test('isGood is case-insensitive and true for correct answer', () {
      final q = Question(
        title: 'Capital of France?',
        choices: ['Paris', 'London'],
        goodChoice: 'Paris',
        point: 10,
      );
      final a = Answer(question: q, answerChoice: 'paris');
      expect(a.isGood(), isTrue);
    });

    test('isGood is false for wrong answer', () {
      final q = Question(
        title: '2 + 2?',
        choices: ['3', '4'],
        goodChoice: '4',
        point: 10,
      );
      final a = Answer(question: q, answerChoice: '3');
      expect(a.isGood(), isFalse);
    });
  });

  group('Quiz - percentage scoring', () {
    test('all correct => 100%', () {
      final q1 = Question(
          title: '4-2', choices: ['1', '2', '3'], goodChoice: '2', point: 10);
      final q2 = Question(
          title: '4+2', choices: ['5', '6', '7'], goodChoice: '6', point: 50);
      final quiz = Quiz(questions: [q1, q2]);
      quiz.addAnswer(Answer(question: q1, answerChoice: '2'));
      quiz.addAnswer(Answer(question: q2, answerChoice: '6'));
      expect(quiz.getScoreInPercentage(), equals(100));
    });

    test('half correct => 50%', () {
      final q1 = Question(
          title: '4-2', choices: ['1', '2', '3'], goodChoice: '2', point: 10);
      final q2 = Question(
          title: '4+2', choices: ['5', '6', '7'], goodChoice: '6', point: 50);
      final quiz = Quiz(questions: [q1, q2]);
      quiz.addAnswer(Answer(question: q1, answerChoice: '2'));
      quiz.addAnswer(Answer(question: q2, answerChoice: '5'));
      expect(quiz.getScoreInPercentage(), equals(50));
    });

    test('no answers => 0%', () {
      final q1 =
          Question(title: 'A', choices: ['x'], goodChoice: 'x', point: 1);
      final q2 =
          Question(title: 'B', choices: ['y'], goodChoice: 'y', point: 1);
      final quiz = Quiz(questions: [q1, q2]);
      expect(quiz.getScoreInPercentage(), equals(0));
    });

    test('truncates decimal percentage (1/3 -> 33%)', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 10);
      final q3 =
          Question(title: 'Q3', choices: ['c'], goodChoice: 'c', point: 10);
      final quiz = Quiz(questions: [q1, q2, q3]);
      quiz.addAnswer(Answer(question: q1, answerChoice: 'a'));
      quiz.addAnswer(Answer(question: q2, answerChoice: 'x'));
      quiz.addAnswer(Answer(question: q3, answerChoice: 'y'));
      expect(quiz.getScoreInPercentage(), equals(33));
    });
  });

  group('Quiz - total points', () {
    test('sums points of correct answers in order', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 50);
      final quiz = Quiz(questions: [q1, q2]);
      quiz.addAnswer(Answer(question: q1, answerChoice: 'a')); // +10
      quiz.addAnswer(Answer(question: q2, answerChoice: 'x')); // +0
      expect(quiz.getTotalPoint(), equals(10));
    });

    test('with fewer answers than questions, sums only provided correct ones',
        () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 50);
      final quiz = Quiz(questions: [q1, q2]);
      quiz.addAnswer(Answer(question: q1, answerChoice: 'a')); // +10
      expect(quiz.getTotalPoint(), equals(10));
    });
  });

  group('Data - JSON provider', () {
    test('loads questions.json and exposes questions array', () async {
      final data = await loadJsonFromFile('lib/data/questions.json');
      expect(data, contains('questions'));
      final raw = data['questions'];
      expect(raw, isA<List<dynamic>>());
      expect(raw.length, greaterThanOrEqualTo(1));
      // spot-check first item shape
      final first = raw.first as Map<String, dynamic>;
      expect(first, contains('title'));
      expect(first, contains('choices'));
      expect(first, contains('goodChoice'));
      expect(first, contains('point'));
    });
  });

  group('Player', () {
    test('creates player with name, totalScore, and answers', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final a1 = Answer(question: q1, answerChoice: 'a');
      final player = Player(name: 'ALICE', totalScore: 10, answers: [a1]);
      expect(player.name, equals('ALICE'));
      expect(player.totalScore, equals(10));
    });

    test('toString returns formatted player info', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final a1 = Answer(question: q1, answerChoice: 'a');
      final player = Player(name: 'DAVE', totalScore: 80, answers: [a1]);
      expect(player.toString(), equals('Player: DAVE     Score: 80'));
    });
  });
}
