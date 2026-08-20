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
    super.key,
    required this.quest,
    required this.stars,
    required this.xpEarned,
    required this.nextQuestId,
  });

  static Future<void> show(
    BuildContext context,
    Quest quest,
    int stars,
    int xpEarned,
    String nextQuestId,
  ) async {
    SoundEngine().playVictoryFanfare();

    // Update profiel
    final profile = context.read<PlayerProfile>();
    await profile.addXP(xpEarned);
    await profile.completeQuest(quest.id, stars);
    if (nextQuestId.isNotEmpty) {
      await profile.unlockNode(nextQuestId);
    }

    if (!context.mounted) return;

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
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AxiomTheme.accentGold, width: 3),
          boxShadow: [
            BoxShadow(
              color: AxiomTheme.accentGold.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 6,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AxiomTheme.accentGold, size: 54),
            const SizedBox(height: 12),
            Text(
              "MISSIE VOLTOOID!",
              textAlign: TextAlign.center,
              style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
                color: AxiomTheme.accentGold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quest.title,
              style: const TextStyle(
                color: AxiomTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: AxiomTheme.accentGold,
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AxiomTheme.primaryCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AxiomTheme.primaryCyan.withValues(alpha: 0.5)),
              ),
              child: Text(
                "+$xpEarned XP VERDIEND",
                style: const TextStyle(
                  color: AxiomTheme.primaryCyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AxiomTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Sluit dialoog
                  Navigator.of(context).pop(); // Terug naar dashboard
                },
                child: const Text(
                  "TERUG NAAR OVERZICHT",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
