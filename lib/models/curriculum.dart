class GameDomain {
  final String id;
  final String title;
  final String description;
  final List<Chapter> chapters;

  GameDomain({required this.id, required this.title, required this.description, required this.chapters});
}

class Chapter {
  final String id;
  final String title;
  final List<Quest> quests;

  Chapter({required this.id, required this.title, required this.quests});
}

enum QuestType {
  fusion, // Herleiden & Machten
  forge,  // Haakjes wegwerken
  balance, // Vergelijkingen oplossen
  inequality // Ongelijkheden
}

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final int baseXP;
  final String description;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.baseXP,
    required this.description,
  });
}

// Sample Data
final world1 = GameDomain(
  id: 'domein_ab',
  title: 'Domein A/B: Algebraïsche Vaardigheden',
  description: 'Master the elements of algebra.',
  chapters: [
    Chapter(
      id: 'chap_1',
      title: 'Les 7: Basis Algebra',
      quests: [
        Quest(id: 'q1', title: 'Element Fusion', type: QuestType.fusion, baseXP: 100, description: 'Herleiden & Machten'),
        Quest(id: 'q2', title: 'The Alchemist\'s Forge', type: QuestType.forge, baseXP: 150, description: 'Haakjes Wegwerken & Ontbinden'),
        Quest(id: 'q3', title: 'Scale of Truth', type: QuestType.balance, baseXP: 200, description: 'Balansmethode & Lineaire Vergelijkingen'),
        Quest(id: 'q4', title: 'Dimension Flip', type: QuestType.inequality, baseXP: 250, description: 'Ongelijkheden & Minteken'),
      ],
    ),
  ],
);
