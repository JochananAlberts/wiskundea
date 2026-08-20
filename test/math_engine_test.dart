import 'package:flutter_test/flutter_test.dart';
import 'package:axiom_rpg/utils/math_parser.dart';
import 'package:axiom_rpg/generators/math_generator.dart';
import 'package:axiom_rpg/models/generated_problem.dart';

void main() {
  group('MathParser Tests', () {
    test('Normalizes powers and spaces', () {
      expect(MathParser.normalize('2x² - 4x + 7'), '2x^2-4x+7');
      expect(MathParser.normalize('13x - 4x + 3x'), '13x-4x+3x');
      expect(MathParser.normalize('x · y'), 'x*y');
    });

    test('Checks polynomial equivalence with different term order', () {
      expect(
        MathParser.isEquivalent(
          userInput: '6a^2 - 15b^2 - ab',
          canonicalAnswer: '6a^2 - ab - 15b^2',
        ),
        isTrue,
      );
      expect(
        MathParser.isEquivalent(
          userInput: '12x + 4y',
          canonicalAnswer: '4y + 12x',
        ),
        isTrue,
      );
    });

    test('Validates linear equation answers with decimal rounding', () {
      final res1 = MathParser.validateEquationAnswer(
        userInput: 'x = 5',
        variable: 'x',
        targetAnswer: 5.0,
      );
      expect(res1.isValid, isTrue);

      final res2 = MathParser.validateEquationAnswer(
        userInput: 't = 6.45',
        variable: 't',
        targetAnswer: 35.5 / 5.5, // 6.4545...
      );
      expect(res2.isValid, isTrue);
    });

    test('Validates inequality answers with flipped operators', () {
      final res1 = MathParser.validateInequalityAnswer(
        userInput: 't < 3',
        variable: 't',
        expectedOperator: '<',
        targetValue: 3.0,
      );
      expect(res1.isValid, isTrue);

      final res2 = MathParser.validateInequalityAnswer(
        userInput: 't >= -3.33',
        variable: 't',
        expectedOperator: '>=',
        targetValue: -20.0 / 6.0,
      );
      expect(res2.isValid, isTrue);

      // Warning when sign is NOT flipped
      final res3 = MathParser.validateInequalityAnswer(
        userInput: 't <= -3.33',
        variable: 't',
        expectedOperator: '>=',
        targetValue: -20.0 / 6.0,
      );
      expect(res3.isValid, isFalse);
      expect(res3.feedback.contains('klapregel'), isTrue);
    });
  });

  group('QuestionGenerator Tests', () {
    test('Generates valid problems across all 4 quests and 3 tiers', () {
      final quests = ['q1', 'q2', 'q3', 'q4'];
      for (final q in quests) {
        for (final tier in DifficultyTier.values) {
          final problem = QuestionGenerator.generate(questId: q, tier: tier);
          expect(problem.latexPrompt.isNotEmpty, isTrue);
          expect(problem.canonicalAnswer.isNotEmpty, isTrue);
        }
      }
    });
  });
}
