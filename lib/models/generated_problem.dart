enum DifficultyTier {
  makkelijk,  // Tier 1
  gemiddeld,  // Tier 2
  vwoMoeilijk // Tier 3
}

class GeneratedProblem {
  final String id;
  final String questId;
  final DifficultyTier tier;
  final String instruction;
  final String latexPrompt;
  final String canonicalAnswer;
  final List<String> acceptedAnswers;
  final String variable;
  final bool isEquationOrInequality;
  final double? targetValue;
  final String? targetOperator; // '=', '<', '>', '<=', '>='
  final String didacticHint;

  GeneratedProblem({
    required this.id,
    required this.questId,
    required this.tier,
    required this.instruction,
    required this.latexPrompt,
    required this.canonicalAnswer,
    required this.acceptedAnswers,
    this.variable = 'x',
    this.isEquationOrInequality = false,
    this.targetValue,
    this.targetOperator,
    required this.didacticHint,
  });

  String get tierName {
    switch (tier) {
      case DifficultyTier.makkelijk:
        return 'Niveau 1: Makkelijk';
      case DifficultyTier.gemiddeld:
        return 'Niveau 2: Gemiddeld';
      case DifficultyTier.vwoMoeilijk:
        return 'Niveau 3: VWO Niveau';
    }
  }
}
