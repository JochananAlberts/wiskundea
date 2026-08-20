import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../models/player_profile.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import 'quest_router.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfile>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 4,
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: AxiomTheme.accentGold, size: 28),
            const SizedBox(width: 10),
            Text(
              'Axiom: VWO Wiskunde A',
              style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
                fontSize: 22,
                color: AxiomTheme.textWhite,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AxiomTheme.accentGold.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech, color: AxiomTheme.accentGold, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Niveau ${profile.level}',
                  style: const TextStyle(
                    color: AxiomTheme.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('|', style: TextStyle(color: Colors.white38)),
                const SizedBox(width: 10),
                const Icon(Icons.flash_on, color: AxiomTheme.primaryCyan, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${profile.xp} XP',
                  style: const TextStyle(
                    color: AxiomTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: SoundEngine().isMuted ? 'Geluid aanzetten' : 'Geluid dempen',
            icon: Icon(
              SoundEngine().isMuted ? Icons.volume_off : Icons.volume_up,
              color: AxiomTheme.primaryCyan,
            ),
            onPressed: () {
              setState(() {
                SoundEngine().toggleMute();
              });
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AxiomTheme.background, Color(0xFF131720), Color(0xFF0A0D12)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AxiomTheme.primaryPurple.withValues(alpha: 0.35),
                    const Color(0xFF161B22),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: AxiomTheme.primaryCyan, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          world1.title,
                          style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            color: AxiomTheme.primaryCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    world1.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ...world1.chapters.map((chapter) => _buildChapter(context, chapter, profile)),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(BuildContext context, Chapter chapter, PlayerProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars, color: AxiomTheme.accentGold, size: 22),
            const SizedBox(width: 8),
            Text(
              chapter.title,
              style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
                fontSize: 22,
                color: AxiomTheme.textWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 900
                ? (constraints.maxWidth - 48) / 3
                : constraints.maxWidth > 600
                    ? (constraints.maxWidth - 24) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: chapter.quests
                  .map((q) => SizedBox(
                        width: cardWidth,
                        child: _buildQuestCard(context, q, profile),
                      ))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuestCard(BuildContext context, Quest quest, PlayerProfile profile) {
    final bool isUnlocked = profile.unlockedNodes.contains(quest.id);
    final int stars = profile.questStars[quest.id] ?? 0;

    return MouseRegion(
      cursor: isUnlocked ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            SoundEngine().playClickSound();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuestRouter(quest: quest)),
            );
          } else {
            SoundEngine().playErrorSound();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speel eerst de vorige missie uit om deze te ontgrendelen!'),
                duration: Duration(seconds: 2),
                backgroundColor: AxiomTheme.primaryPurple,
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFF161B22) : Colors.black45,
            border: Border.all(
              color: isUnlocked ? AxiomTheme.primaryPurple : Colors.grey.shade800,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: AxiomTheme.primaryPurple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AxiomTheme.primaryCyan.withValues(alpha: 0.15)
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getQuestIcon(quest.type),
                      color: isUnlocked ? AxiomTheme.primaryCyan : Colors.grey.shade700,
                      size: 28,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: isUnlocked ? AxiomTheme.accentGold : Colors.grey.shade800,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                quest.title,
                style: const TextStyle(
                  color: AxiomTheme.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                quest.description,
                style: TextStyle(
                  color: isUnlocked ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              // LaTeX Formula Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUnlocked ? Colors.white12 : Colors.grey.shade900,
                  ),
                ),
                child: Center(
                  child: Math.tex(
                    quest.mathSummary,
                    textStyle: TextStyle(
                      fontSize: 13,
                      color: isUnlocked ? AxiomTheme.accentGold : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '+${quest.baseXP} XP',
                    style: TextStyle(
                      color: isUnlocked ? AxiomTheme.primaryCyan : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AxiomTheme.primaryPurple.withValues(alpha: 0.4)
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isUnlocked ? (stars > 0 ? 'Opnieuw spelen' : 'Start Missie') : 'Vergrendeld',
                      style: TextStyle(
                        color: isUnlocked ? AxiomTheme.textWhite : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.simplify:
        return Icons.calculate_outlined;
      case QuestType.brackets:
        return Icons.auto_fix_high;
      case QuestType.equations:
        return Icons.balance;
      case QuestType.inequality:
        return Icons.swap_horiz;
    }
  }
}
