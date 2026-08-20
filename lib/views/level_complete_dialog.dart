import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/curriculum.dart';
import '../models/player_profile.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';

class LevelCompleteDialog extends StatelessWidget {
  final Quest quest;
  final int stars;
  final int xpEarned;
  final String nextQuestId;

  const LevelCompleteDialog({
    Key? key,
    required this.quest,
    required this.stars,
    required this.xpEarned,
    required this.nextQuestId,
  }) : super(key: key);

  static Future<void> show(BuildContext context, Quest quest, int stars, int xpEarned, String nextQuestId) async {
    SoundEngine().playVictoryFanfare();
    
    // Update profile
    final profile = context.read<PlayerProfile>();
    await profile.addXP(xpEarned);
    await profile.completeQuest(quest.id, stars);
    if (nextQuestId.isNotEmpty) {
      await profile.unlockNode(nextQuestId);
    }
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LevelCompleteDialog(
        quest: quest,
        stars: stars,
        xpEarned: xpEarned,
        nextQuestId: nextQuestId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AxiomTheme.themeData.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AxiomTheme.accentGold, width: 3),
          boxShadow: [
            BoxShadow(color: AxiomTheme.accentGold.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("QUEST COMPLETE!", style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(color: AxiomTheme.accentGold)),
            const SizedBox(height: 16),
            Text(quest.title, style: AxiomTheme.themeData.textTheme.bodyLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: AxiomTheme.accentGold,
                size: 48,
              )),
            ),
            const SizedBox(height: 24),
            Text("+$xpEarned XP", style: const TextStyle(color: AxiomTheme.primaryCyan, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to dashboard
              },
              child: const Text("CONTINUE"),
            )
          ],
        ),
      ),
    );
  }
}
