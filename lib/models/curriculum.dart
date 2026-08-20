import 'generated_problem.dart';

class GameDomain {
  final String id;
  final String title;
  final String description;
  final List<Chapter> chapters;

  GameDomain({
    required this.id,
    required this.title,
    required this.description,
    required this.chapters,
  });
}

class Chapter {
  final String id;
  final String title;
  final List<Quest> quests;

  Chapter({
    required this.id,
    required this.title,
    required this.quests,
  });
}

enum QuestType {
  simplify,   // Quest 1: Herleiden
  brackets,   // Quest 2: Haakjes & Factoren
  equations,  // Quest 3: Vergelijkingen
  inequality, // Quest 4: Ongelijkheden
}

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final int baseXP;
  final String description;
  final String mathSummary;
  final Map<DifficultyTier, String> tierDescriptions;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.baseXP,
    required this.description,
    required this.mathSummary,
    required this.tierDescriptions,
  });
}

// Curriculum data voor VWO Wiskunde A (4 procedurale missies)
final world1 = GameDomain(
  id: 'domein_ab',
  title: 'Domein A/B: Algebraïsche Vaardigheden',
  description: 'Train je algebraïsche vaardigheden met oneindig veel procedurale opgaven op echt VWO niveau.',
  chapters: [
    Chapter(
      id: 'chap_1',
      title: 'VWO Wiskunde A: Algebraïsche Kernvaardigheden',
      quests: [
        Quest(
          id: 'q1',
          title: 'Quest 1: Herleiden & Machten',
          type: QuestType.simplify,
          baseXP: 100,
          description: 'Gelijksoortige termen optellen, machten vermenigvuldigen en breuken herleiden.',
          mathSummary: r'\frac{24x^7y^3}{6xy^2} + 2x^6y = 6x^6y',
          tierDescriptions: {
            DifficultyTier.makkelijk: 'Optellen en aftrekken van gelijksoortige termen.',
            DifficultyTier.gemiddeld: 'Vermenigvuldigen van machten met exponenten.',
            DifficultyTier.vwoMoeilijk: 'Complexe breuken met gemengde variabelen en machten.',
          },
        ),
        Quest(
          id: 'q2',
          title: 'Quest 2: Haakjes & Factoren',
          type: QuestType.brackets,
          baseXP: 150,
          description: 'Enkele haakjes, dubbele haakjes (papegaaienbek) en gecombineerde uitdrukkingen.',
          mathSummary: r'(2a + 3b)(3a - 5b) = 6a^2 - ab - 15b^2',
          tierDescriptions: {
            DifficultyTier.makkelijk: 'Enkele haakjes uitwerken met negatieve factoren.',
            DifficultyTier.gemiddeld: 'Dubbele haakjes uitwerken en herleiden.',
            DifficultyTier.vwoMoeilijk: 'Gecombineerde uitdrukkingen met meerdere haakjes en mintekens.',
          },
        ),
        Quest(
          id: 'q3',
          title: 'Quest 3: Vergelijkingen Oplossen',
          type: QuestType.equations,
          baseXP: 200,
          description: 'Balansmethode, haakjes aan beide zijden en vergelijkingen met breuken.',
          mathSummary: r'\frac{1}{4}(2t - 2) - 8 = -5(t - 6) - 3',
          tierDescriptions: {
            DifficultyTier.makkelijk: 'Basis balansmethode met variabelen aan beide kanten.',
            DifficultyTier.gemiddeld: 'Vergelijkingen met haakjes aan beide zijden.',
            DifficultyTier.vwoMoeilijk: 'Complexe VWO-vergelijkingen met breuken en afronding.',
          },
        ),
        Quest(
          id: 'q4',
          title: 'Quest 4: Ongelijkheden & Minteken',
          type: QuestType.inequality,
          baseXP: 250,
          description: 'Lineaire ongelijkheden en de klapregel bij delen door een negatief getal.',
          mathSummary: r'-4(t + 4) \le 2t + 4 \implies t \ge -3.33',
          tierDescriptions: {
            DifficultyTier.makkelijk: 'Standaard lineaire ongelijkheden.',
            DifficultyTier.gemiddeld: 'Ongelijkheden met haakjes en minteken klapregel.',
            DifficultyTier.vwoMoeilijk: 'Complexe ongelijkheden met meerdere stappen en breuken.',
          },
        ),
      ],
    ),
  ],
);
