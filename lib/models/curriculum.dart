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
  forge,     // Haakjes wegwerken & Ontbinden
  balance,   // Balansmethode & Lineaire vergelijkingen
  inequality // Ongelijkheden & Mintekenregel
}

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final int baseXP;
  final String description;
  final String mathSummary;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.baseXP,
    required this.description,
    required this.mathSummary,
  });
}

// Curriculum voor VWO Wiskunde A (3 kernvaardigheden)
final world1 = GameDomain(
  id: 'domein_ab',
  title: 'Domein A/B: Algebraïsche Vaardigheden',
  description: 'Beheers haakjes wegwerken, ontbinden in factoren, de balansmethode en ongelijkheden.',
  chapters: [
    Chapter(
      id: 'chap_1',
      title: 'Hoofdstuk 1: Algebra & Vergelijkingen',
      quests: [
        Quest(
          id: 'q1',
          title: 'De Alchemisten Smederij',
          type: QuestType.forge,
          baseXP: 150,
          description: 'Haakjes wegwerken en ontbinden in factoren.',
          mathSummary: r'3a(2a - 5b) \quad \text{en} \quad 6p^2 - 10pq',
        ),
        Quest(
          id: 'q2',
          title: 'Weegschaal der Waarheid',
          type: QuestType.balance,
          baseXP: 200,
          description: 'Lineaire vergelijkingen oplossen met de balansmethode.',
          mathSummary: r'5q - 22 = -2q + 48 \implies q = 10',
        ),
        Quest(
          id: 'q3',
          title: 'Dimensie Klap (Ongelijkheden)',
          type: QuestType.inequality,
          baseXP: 250,
          description: 'Lineaire ongelijkheden oplossen met de mintekenregel.',
          mathSummary: r'-5t > -15 \implies t < 3',
        ),
      ],
    ),
  ],
);
