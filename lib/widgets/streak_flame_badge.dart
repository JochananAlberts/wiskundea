import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class StreakFlameBadge extends StatelessWidget {
  final int streakCount;

  const StreakFlameBadge({super.key, required this.streakCount});

  double get multiplier {
    if (streakCount >= 6) return 3.0;
    if (streakCount >= 3) return 2.0;
    if (streakCount >= 1) return 1.5;
    return 1.0;
  }

  Color get flameColor {
    if (streakCount >= 6) return const Color(0xFFFF3D00); // Rood-oranje vuur
    if (streakCount >= 3) return AxiomTheme.accentGold;   // Goud vuur
    if (streakCount >= 1) return AxiomTheme.primaryCyan;  // Cyaan vlam
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: flameColor.withValues(alpha: streakCount > 0 ? 0.8 : 0.2),
          width: 1.5,
        ),
        boxShadow: streakCount > 0
            ? [
                BoxShadow(
                  color: flameColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: flameColor,
            size: 20,
          ).animate(target: streakCount > 0 ? 1 : 0).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.25, 1.25),
                duration: 300.ms,
              ),
          const SizedBox(width: 6),
          Text(
            'Streak: $streakCount',
            style: TextStyle(
              color: streakCount > 0 ? AxiomTheme.textWhite : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          if (streakCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: flameColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${multiplier}x XP',
                style: TextStyle(
                  color: flameColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
