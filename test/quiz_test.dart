import 'package:quiz/domain/quiz.dart';
import 'package:quiz/data/quiz_file_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Question', () {
    test('auto-generates a UUID id when not provided', () {
      final q = Question(
        title: 'Q',
        choices: ['a', 'b'],
        goodChoice: 'a',
        point: 5,
      );
      expect(q.id, isNotEmpty);
    });

    test('uses provided id when specified', () {
      final q = Question(
        id: 'custom-id-123',
        title: 'Q',
        choices: ['a', 'b'],
        goodChoice: 'a',
        point: 5,
      );
      expect(q.id, equals('custom-id-123'));
    });
  });

  group('Answer', () {
    test('stores only question ID, not full question object', () {
      final a = Answer(questionId: 'q123', answerChoice: 'Paris');
      expect(a.questionId, equals('q123'));
      expect(a.answerChoice, equals('Paris'));
    });

    test('isCorrect is case-insensitive and true for correct answer', () {
      final q = Question(
        title: 'Capital of France?',
        choices: ['Paris', 'London'],
        goodChoice: 'Paris',
        point: 10,
      );
      final a = Answer(questionId: q.id, answerChoice: 'paris');
      expect(a.isCorrect(q), isTrue);
    });

    test('isCorrect is false for wrong answer', () {
      final q = Question(
        title: '2 + 2?',
        choices: ['3', '4'],
        goodChoice: '4',
        point: 10,
      );
      final a = Answer(questionId: q.id, answerChoice: '3');
      expect(a.isCorrect(q), isFalse);
    });
  });

  group('Quiz - percentage scoring', () {
    test('all correct => 100%', () {
      final q1 = Question(
          title: '4-2', choices: ['1', '2', '3'], goodChoice: '2', point: 10);
      final q2 = Question(
          title: '4+2', choices: ['5', '6', '7'], goodChoice: '6', point: 50);
      final quiz = Quiz(questions: [q1, q2]);

      final playerAnswers = [
        Answer(questionId: q1.id, answerChoice: '2'),
        Answer(questionId: q2.id, answerChoice: '6'),
      ];
      expect(quiz.getScoreInPercentage(playerAnswers), equals(100));
    });

    test('half correct => 50%', () {
      final q1 = Question(
          title: '4-2', choices: ['1', '2', '3'], goodChoice: '2', point: 10);
      final q2 = Question(
          title: '4+2', choices: ['5', '6', '7'], goodChoice: '6', point: 50);
      final quiz = Quiz(questions: [q1, q2]);

      final playerAnswers = [
        Answer(questionId: q1.id, answerChoice: '2'),
        Answer(questionId: q2.id, answerChoice: '5'),
      ];
      expect(quiz.getScoreInPercentage(playerAnswers), equals(50));
    });

    test('no answers => 0%', () {
      final q1 =
          Question(title: 'A', choices: ['x'], goodChoice: 'x', point: 1);
      final q2 =
          Question(title: 'B', choices: ['y'], goodChoice: 'y', point: 1);
      final quiz = Quiz(questions: [q1, q2]);
      expect(quiz.getScoreInPercentage([]), equals(0));
    });

    test('truncates decimal percentage (1/3 -> 33%)', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 10);
      final q3 =
          Question(title: 'Q3', choices: ['c'], goodChoice: 'c', point: 10);
      final quiz = Quiz(questions: [q1, q2, q3]);

      final playerAnswers = [
        Answer(questionId: q1.id, answerChoice: 'a'),
        Answer(questionId: q2.id, answerChoice: 'x'),
        Answer(questionId: q3.id, answerChoice: 'y'),
      ];
      expect(quiz.getScoreInPercentage(playerAnswers), equals(33));
    });
  });

  group('Quiz - total points', () {
    test('sums points of correct answers', () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 50);
      final quiz = Quiz(questions: [q1, q2]);

      final playerAnswers = [
        Answer(questionId: q1.id, answerChoice: 'a'), // +10
        Answer(questionId: q2.id, answerChoice: 'x'), // +0
      ];
      expect(quiz.getTotalPoints(playerAnswers), equals(10));
    });

    test('with fewer answers than questions, sums only provided correct ones',
        () {
      final q1 =
          Question(title: 'Q1', choices: ['a'], goodChoice: 'a', point: 10);
      final q2 =
          Question(title: 'Q2', choices: ['b'], goodChoice: 'b', point: 50);
      final quiz = Quiz(questions: [q1, q2]);

      final playerAnswers = [
        Answer(questionId: q1.id, answerChoice: 'a'), // +10
      ];
      expect(quiz.getTotalPoints(playerAnswers), equals(10));
    });
  });

  group('Data - JSON provider', () {
    test('loads questions from questions.json', () async {
      final questions = await loadQuestions();
      expect(questions, isNotEmpty);
      expect(questions.first.title, isNotEmpty);
      expect(questions.first.choices, isNotEmpty);
    });
  });

  group('Player', () {
    test('creates player with name, totalScore, and answers', () {
      final a1 = Answer(questionId: 'q1', answerChoice: 'a');
      final player = Player(name: 'ALICE', totalScore: 10, answers: [a1]);
      expect(player.name, equals('ALICE'));
      expect(player.totalScore, equals(10));
      expect(player.answers.length, equals(1));
    });

    test('toString returns formatted player info', () {
      final a1 = Answer(questionId: 'q1', answerChoice: 'a');
      final player = Player(name: 'DAVE', totalScore: 80, answers: [a1]);
      expect(player.toString(), equals('Player: DAVE     Score: 80'));
    });

    test('can serialize to/from JSON', () {
      final a1 = Answer(questionId: 'q1', answerChoice: 'Paris');
      final player = Player(name: 'BOB', totalScore: 50, answers: [a1]);

      final json = player.toJson();
      final restored = Player.fromJson(json);

      expect(restored.name, equals('BOB'));
      expect(restored.totalScore, equals(50));
      expect(restored.answers.length, equals(1));
      expect(restored.answers.first.questionId, equals('q1'));
    });
  });
}
