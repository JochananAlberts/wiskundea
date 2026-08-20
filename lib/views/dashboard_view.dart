import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_profile.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import 'quest_router.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfile>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Axiom RPG', style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(fontSize: 24)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('LVL ${profile.level} | XP: ${profile.xp}', 
                style: const TextStyle(color: AxiomTheme.accentGold, fontWeight: FontWeight.bold)
              ),
            ),
          ),
          IconButton(
            icon: Icon(SoundEngine().isMuted ? Icons.volume_off : Icons.volume_up, color: AxiomTheme.primaryCyan),
            onPressed: () {
              SoundEngine().toggleMute();
              (context as Element).markNeedsBuild(); // quick hack to refresh icon
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AxiomTheme.background, Color(0xFF161B22)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(world1.title, style: AxiomTheme.themeData.textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(world1.description, style: AxiomTheme.themeData.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 32),
            
            ...world1.chapters.map((chapter) => _buildChapter(context, chapter, profile)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(BuildContext context, Chapter chapter, PlayerProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(chapter.title, style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(fontSize: 28, color: AxiomTheme.primaryCyan)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: chapter.quests.map((q) => _buildQuestNode(context, q, profile)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestNode(BuildContext context, Quest quest, PlayerProfile profile) {
    bool isUnlocked = profile.unlockedNodes.contains(quest.id);
    int stars = profile.questStars[quest.id] ?? 0;
    
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          SoundEngine().playClickSound();
          Navigator.push(context, MaterialPageRoute(builder: (_) => QuestRouter(quest: quest)));
        } else {
          SoundEngine().playErrorSound();
        }
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? AxiomTheme.themeData.cardTheme.color : Colors.black45,
          border: Border.all(
            color: isUnlocked ? AxiomTheme.primaryPurple : Colors.grey.shade800,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUnlocked ? [
            BoxShadow(color: AxiomTheme.primaryPurple.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              _getQuestIcon(quest.type), 
              color: isUnlocked ? AxiomTheme.primaryCyan : Colors.grey.shade700,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              quest.title,
              textAlign: TextAlign.center,
              style: AxiomTheme.themeData.textTheme.labelLarge?.copyWith(
                color: isUnlocked ? AxiomTheme.textWhite : Colors.grey.shade600,
                fontSize: 10
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: isUnlocked ? AxiomTheme.accentGold : Colors.grey.shade800,
                size: 16,
              )),
            )
          ],
        ),
      ),
    );
  }

  IconData _getQuestIcon(QuestType type) {
    switch (type) {
      case QuestType.fusion: return Icons.merge_type;
      case QuestType.forge: return Icons.handyman;
      case QuestType.balance: return Icons.scale;
      case QuestType.inequality: return Icons.compare_arrows;
    }
  }
}
