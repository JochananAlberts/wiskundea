import 'dart:math';
import '../models/generated_problem.dart';

class QuestionGenerator {
  static final Random _rng = Random();

  /// Genereert een nieuwe opgave op basis van questId ('q1', 'q2', 'q3', 'q4') en moeilijkheidsgraad.
  static GeneratedProblem generate({
    required String questId,
    required DifficultyTier tier,
  }) {
    switch (questId) {
      case 'q1':
        return _generateSimplifyProblem(tier);
      case 'q2':
        return _generateBracketsProblem(tier);
      case 'q3':
        return _generateEquationProblem(tier);
      case 'q4':
        return _generateInequalityProblem(tier);
      default:
        return _generateSimplifyProblem(tier);
    }
  }

  // ==========================================
  // QUEST 1: HERLEIDEN (SIMPLIFYING)
  // ==========================================
  static GeneratedProblem _generateSimplifyProblem(DifficultyTier tier) {
    final id = 'sim_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    const vars = ['x', 'a', 'y', 'p'];
    final v = vars[_rng.nextInt(vars.length)];

    if (tier == DifficultyTier.makkelijk) {
      // Optellen / aftrekken van 4 termen: c1*x - c2*x + c3*x - c4*x
      final c1 = _rng.nextInt(15) + 5; // 5..19
      final c2 = _rng.nextInt(8) + 2;  // 2..9
      final c3 = _rng.nextInt(10) + 3; // 3..12
      final c4 = _rng.nextInt(7) + 2;  // 2..8
      final ansCoeff = c1 - c2 + c3 - c4;

      final prompt = '$c1$v - $c2$v + $c3$v - $c4$v';
      final ans = _formatSingleTerm(ansCoeff, v);

      return GeneratedProblem(
        id: id,
        questId: 'q1',
        tier: tier,
        instruction: 'Herleid de uitdrukking zo ver mogelijk:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans],
        variable: v,
        didacticHint: 'Tel de coëfficiënten van de gelijksoortige termen bij elkaar op.',
      );
    } else if (tier == DifficultyTier.gemiddeld) {
      // Machten vermenigvuldigen: a*x^p * b*x^q - c*x^1 * d*x^n (met p+q = 1+n)
      final p = _rng.nextInt(3) + 2; // 2..4
      final q = _rng.nextInt(3) + 1; // 1..3
      final totalExp = p + q;
      final n = totalExp - 1;

      final a = _rng.nextInt(4) + 2; // 2..5
      final b = _rng.nextInt(4) + 2; // 2..5
      final c = _rng.nextInt(3) + 2; // 2..4
      final d = _rng.nextInt(3) + 1; // 1..3

      final term1Coeff = a * b;
      final term2Coeff = c * d;
      final totalCoeff = term1Coeff - term2Coeff;

      final prompt = '$a$v^{$p} \\cdot $b$v^{$q} - $c$v \\cdot $d$v^{$n}';
      final ans = _formatPowerTerm(totalCoeff, v, totalExp);

      return GeneratedProblem(
        id: id,
        questId: 'q1',
        tier: tier,
        instruction: r'Herleid en pas de rekenregels voor machten toe:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans],
        variable: v,
        didacticHint: 'Vermenigvuldig eerst de getallen en tel bij vermenigvuldigen van machten de exponenten op.',
      );
    } else {
      // Tier 3 (VWO Moeilijk): Breuk met gemengde variabelen + extra term
      final xExp = _rng.nextInt(4) + 4; // 4..7
      final yExp = _rng.nextInt(3) + 2; // 2..4

      final bDen = _rng.nextInt(4) + 2; // 2..5
      final multiplier = _rng.nextInt(4) + 2; // 2..5
      final aNum = bDen * multiplier; // deelbaar

      final extraCoeff = _rng.nextInt(4) + 1; // 1..4
      final totalCoeff = multiplier + extraCoeff;

      final resXExp = xExp - 1;
      final resYExp = yExp - 1;

      final prompt = '\\frac{$aNum x^{$xExp} y^{$yExp}}{$bDen x y} + $extraCoeff x^{$resXExp} y^{$resYExp}';
      final ans = '${totalCoeff}x^{$resXExp}y^{$resYExp}';
      final alt1 = '${totalCoeff}x^$resXExp*y^$resYExp';
      final alt2 = '${totalCoeff}y^{$resYExp}x^{$resXExp}';

      return GeneratedProblem(
        id: id,
        questId: 'q1',
        tier: tier,
        instruction: 'Vereenvoudig de breuk en herleid de uitdrukking:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, alt1, alt2],
        variable: 'x',
        didacticHint: 'Deel de getallen door elkaar en trek bij delen van machten de exponenten van elkaar af.',
      );
    }
  }

  // ==========================================
  // QUEST 2: HAAKJES & FACTOREN (BRACKETS & FACTORING)
  // ==========================================
  static GeneratedProblem _generateBracketsProblem(DifficultyTier tier) {
    final id = 'brk_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    if (tier == DifficultyTier.makkelijk) {
      // Enkele haakjes met minteken: -a*x(b*x - c*y)
      final a = _rng.nextInt(4) + 2; // 2..5
      final b = _rng.nextInt(4) + 2; // 2..5
      final c = _rng.nextInt(4) + 2; // 2..5

      final term1 = -a * b;
      final term2 = a * c; // min * min = plus

      final prompt = '-$a x($b x - $c y)';
      final ans = '${term1}x^2 + ${term2}xy';
      final alt = '${term2}xy ${term1}x^2';

      return GeneratedProblem(
        id: id,
        questId: 'q2',
        tier: tier,
        instruction: 'Werk de haakjes uit:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, alt, '${term1}x^2+${term2}xy', '${term1}x^2+${term2}yx'],
        variable: 'x',
        didacticHint: 'Let op het minteken vóór de haakjes: min keer min wordt plus!',
      );
    } else if (tier == DifficultyTier.gemiddeld) {
      // Dubbele haakjes: (a*x + b*y)(c*x - d*y)
      final a = _rng.nextInt(3) + 2; // 2..4
      final b = _rng.nextInt(3) + 1; // 1..3
      final c = _rng.nextInt(3) + 2; // 2..4
      final d = _rng.nextInt(3) + 2; // 2..4

      final cX2 = a * c;
      final cXY = (b * c) - (a * d);
      final cY2 = -(b * d);

      final prompt = '($a a + $b b)($c a - $d b)';
      String ans = '${cX2}a^2';
      if (cXY > 0) {
        ans += ' + ${cXY == 1 ? '' : cXY}ab';
      } else if (cXY < 0) {
        ans += ' - ${cXY.abs() == 1 ? '' : cXY.abs()}ab';
      }
      ans += ' - ${cY2.abs()}b^2';

      return GeneratedProblem(
        id: id,
        questId: 'q2',
        tier: tier,
        instruction: 'Werk de dubbele haakjes uit en herleid zo ver mogelijk:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans],
        variable: 'a',
        didacticHint: 'Gebruik de papegaaienbek-methode en herleid de middelste gelijksoortige termen (ab).',
      );
    } else {
      // Tier 3 (VWO Moeilijk): Gecombineerde haakjes met mintekens
      final a = _rng.nextInt(5) + 3; // 3..7
      final b = _rng.nextInt(3) + 1; // 1..3
      final c = _rng.nextInt(4) + 2; // 2..5
      final d = _rng.nextInt(3) + 2; // 2..4
      final e = _rng.nextInt(3) + 2; // 2..4
      final f = _rng.nextInt(3) + 1; // 1..3

      final totalX = a - b + (d * e);
      final totalY = -c + (d * f);

      final prompt = '$a x - ($b x + $c y) + $d($e x + $f y)';

      String ans = '${totalX}x';
      if (totalY > 0) {
        ans += ' + ${totalY == 1 ? '' : totalY}y';
      } else if (totalY < 0) {
        ans += ' - ${totalY.abs() == 1 ? '' : totalY.abs()}y';
      }

      return GeneratedProblem(
        id: id,
        questId: 'q2',
        tier: tier,
        instruction: 'Werk alle haakjes uit en herleid zo ver mogelijk:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans],
        variable: 'x',
        didacticHint: 'Werk eerst alle haakjes zorgvuldig uit en let op het minteken voor de eerste haakjes.',
      );
    }
  }

  // ==========================================
  // QUEST 3: VERGELIJKINGEN (EQUATIONS)
  // ==========================================
  static GeneratedProblem _generateEquationProblem(DifficultyTier tier) {
    final id = 'eq_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    const vars = ['x', 't', 'q', 'y'];
    final v = vars[_rng.nextInt(vars.length)];

    if (tier == DifficultyTier.makkelijk) {
      // Basis balans: a*x = b*x + c -> (a - b)*x = c -> x = c / (a - b)
      final targetInt = _rng.nextInt(12) + 2; // 2..13
      final b = _rng.nextInt(8) + 3; // 3..10
      final diff = _rng.nextInt(6) + 2; // 2..7
      final a = b + diff;
      final c = diff * targetInt;

      final prompt = '$a$v = $b$v + $c';
      final ans = '$v = $targetInt';

      return GeneratedProblem(
        id: id,
        questId: 'q3',
        tier: tier,
        instruction: 'Los de lineaire vergelijking op:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, '$targetInt', '$v=$targetInt'],
        variable: v,
        isEquationOrInequality: true,
        targetValue: targetInt.toDouble(),
        targetOperator: '=',
        didacticHint: 'Trek aan beide zijden $b$v af en deel vervolgens door de coëfficiënt van $v.',
      );
    } else if (tier == DifficultyTier.gemiddeld) {
      final a = _rng.nextInt(4) + 3; // 3..6
      final b = _rng.nextInt(5) + 2; // 2..6
      final c = _rng.nextInt(4) + 3; // 3..6
      final targetX = _rng.nextInt(10) + 1; // 1..10

      final rhsConst = (a * targetX - a * b + c * targetX);
      final d = rhsConst;

      final prompt = '$a($v - $b) = -$c $v + $d';
      final ans = '$v = $targetX';

      return GeneratedProblem(
        id: id,
        questId: 'q3',
        tier: tier,
        instruction: 'Los de vergelijking op (werk eerst de haakjes uit):',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, '$targetX', '$v=$targetX'],
        variable: v,
        isEquationOrInequality: true,
        targetValue: targetX.toDouble(),
        targetOperator: '=',
        didacticHint: 'Werk eerst de haakjes aan de linkerkant uit en breng alle termen met $v naar links.',
      );
    } else {
      const fracDen = 4;
      const fracNum = 2;
      const c1 = 2;
      const c2 = 8;
      const e = 5;
      const f = 6;
      const g = 3;

      const target = 35.5 / 5.5; // ~6.45
      final roundedTarget = (target * 100).round() / 100;

      final prompt = '\\frac{1}{$fracDen}($fracNum $v - $c1) - $c2 = -$e($v - $f) - $g';
      final ans = '$v = $roundedTarget';

      return GeneratedProblem(
        id: id,
        questId: 'q3',
        tier: tier,
        instruction: 'Los de vergelijking op (rond indien nodig af op 2 decimalen):',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, '$roundedTarget', '$v=$roundedTarget', roundedTarget.toString().replaceAll('.', ',')],
        variable: v,
        isEquationOrInequality: true,
        targetValue: target,
        targetOperator: '=',
        didacticHint: 'Werk de breuk en haakjes stap voor stap uit en verzamel alle getallen aan de rechterkant.',
      );
    }
  }

  // ==========================================
  // QUEST 4: ONGELIJKHEDEN (INEQUALITIES)
  // ==========================================
  static GeneratedProblem _generateInequalityProblem(DifficultyTier tier) {
    final id = 'ineq_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    const vars = ['t', 'x', 'a'];
    final v = vars[_rng.nextInt(vars.length)];

    if (tier == DifficultyTier.makkelijk) {
      final targetVal = _rng.nextInt(6) + 2; // 2..7
      const a = 25;
      const c = 30;
      const diff = a - c; // -5
      const b = 70;
      const d = b + (diff * 3); // 55

      final prompt = '$a$v + $b > $c$v + $d';
      final ans = '$v < $targetVal';

      return GeneratedProblem(
        id: id,
        questId: 'q4',
        tier: tier,
        instruction: 'Los de lineaire ongelijkheid op:',
        latexPrompt: prompt,
        canonicalAnswer: ans,
        acceptedAnswers: [ans, '$v<$targetVal'],
        variable: v,
        isEquationOrInequality: true,
        targetValue: targetVal.toDouble(),
        targetOperator: '<',
        didacticHint: 'Vergeet niet: bij het delen door een negatief getal draait het > teken om naar <!',
      );
    } else if (tier == DifficultyTier.gemiddeld) {
      const a = 4;
      const b = 4;
      const c = 2;
      const d = 4;

      const target = -20.0 / 6.0;
      final roundedTarget = (target * 100).round() / 100; // -3.33

      final prompt = '-$a($v + $b) \\le $c$v + $d';
      final ans = '$v \\ge $roundedTarget';
      final ansText = '$v >= $roundedTarget';

      return GeneratedProblem(
        id: id,
        questId: 'q4',
        tier: tier,
        instruction: 'Los de ongelijkheid op (rond af op 2 decimalen en let op de klapregel):',
        latexPrompt: prompt,
        canonicalAnswer: ansText,
        acceptedAnswers: [ansText, ans, '$v>=$roundedTarget', '$v \\ge $roundedTarget'],
        variable: v,
        isEquationOrInequality: true,
        targetValue: target,
        targetOperator: '>=',
        didacticHint: 'Omdat je aan het eind deelt door een negatief getal (-6), klapt <= om naar >=.',
      );
    } else {
      const targetVal = -11.0;
      final prompt = '3(2$v - 5) - 4($v + 2) \\ge 5$v + 10';
      final ans = '$v \\le ${targetVal.round()}';
      final ansText = '$v <= ${targetVal.round()}';

      return GeneratedProblem(
        id: id,
        questId: 'q4',
        tier: tier,
        instruction: 'Werk alle haakjes uit en los de ongelijkheid op:',
        latexPrompt: prompt,
        canonicalAnswer: ansText,
        acceptedAnswers: [ansText, ans, '$v<=${targetVal.round()}'],
        variable: v,
        isEquationOrInequality: true,
        targetValue: targetVal,
        targetOperator: '<=',
        didacticHint: 'Werk alle haakjes zorgvuldig uit en draai het teken om bij het delen door een negatieve coëfficiënt.',
      );
    }
  }

  static String _formatSingleTerm(int coeff, String v) {
    if (coeff == 0) return '0';
    if (coeff == 1) return v;
    if (coeff == -1) return '-$v';
    return '$coeff$v';
  }

  static String _formatPowerTerm(int coeff, String v, int exp) {
    if (coeff == 0) return '0';
    final c = coeff == 1 ? '' : (coeff == -1 ? '-' : '$coeff');
    return '$c$v^$exp';
  }
}
