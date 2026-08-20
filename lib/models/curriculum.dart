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
  fusion,    // Herleiden & Machten
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

// Curriculum data in het Nederlands voor VWO Wiskunde A
final world1 = GameDomain(
  id: 'domein_ab',
  title: 'Domein A/B: Algebraïsche Vaardigheden',
  description: 'Beheers de fundamenten van algebra, machten en vergelijkingen voor het eindexamen.',
  chapters: [
    Chapter(
      id: 'chap_1',
      title: 'Hoofdstuk 1: Basisalgebra & Vergelijkingen',
      quests: [
        Quest(
          id: 'q1',
          title: 'Elementen Fusie',
          type: QuestType.fusion,
          baseXP: 100,
          description: 'Gelijksoortige termen herleiden & rekenregels voor machten.',
          mathSummary: r'3x + 2x = 5x \quad \text{en} \quad 4x^3 \cdot 2x^2 = 8x^5',
        ),
        Quest(
          id: 'q2',
          title: 'De Alchemisten Smederij',
          type: QuestType.forge,
          baseXP: 150,
          description: 'Haakjes wegwerken (distributiviteit) & ontbinden in factoren.',
          mathSummary: r'3a(2a - 5b) = 6a^2 - 15ab \quad \text{en} \quad 6p^2 - 10pq = 2p(3p - 5q)',
        ),
        Quest(
          id: 'q3',
          title: 'Weegschaal der Waarheid',
          type: QuestType.balance,
          baseXP: 200,
          description: 'Lineaire vergelijkingen oplossen met de balansmethode.',
          mathSummary: r'5q - 22 = -2q + 48 \implies q = 10',
        ),
        Quest(
          id: 'q4',
          title: 'Dimensie Klap (Ongelijkheden)',
          type: QuestType.inequality,
          baseXP: 250,
          description: 'Lineaire ongelijkheden oplossen met de klap-het-teken regel bij delen door een negatief getal.',
          mathSummary: r'-5t > -15 \implies t < 3',
        ),
      ],
    ),
  ],
);
