import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class ForgeGame extends StatefulWidget {
  final Quest quest;
  const ForgeGame({Key? key, required this.quest}) : super(key: key);

  @override
  _ForgeGameState createState() => _ForgeGameState();
}

class _ForgeGameState extends State<ForgeGame> {
  // Expansion state: 3a(2a - 5b)
  String multiplier = "3a";
  List<String> termsInside = ["2a", "-5b"];
  List<bool> termExpanded = [false, false];
  List<String> expandedResults = ["6a^2", "-15ab"];
  
  bool isFactoringMode = false; // Phase 2
  
  // Factoring state: 6p^2 - 10pq -> pull out 2p
  String originalExpr = "6p^2 - 10pq";
  List<String> factorOptions = ["2", "p", "2p", "3p"];
  String correctFactor = "2p";
  String factoredResult = "2p(3p - 5q)";
  bool factored = false;

  void _expandTerm(int index) {
    if (!termExpanded[index]) {
      setState(() {
        termExpanded[index] = true;
      });
      SoundEngine().playFusionSound();
      
      if (termExpanded.every((e) => e == true)) {
        // Complete expansion phase
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            isFactoringMode = true;
          });
          SoundEngine().playClickSound();
        });
      }
    }
  }

  void _attemptFactor(String factor) {
    if (factor == correctFactor) {
      setState(() {
        factored = true;
      });
      SoundEngine().playFusionSound();
      Future.delayed(const Duration(milliseconds: 1000), () {
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q3');
      });
    } else {
      SoundEngine().playErrorSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isFactoringMode ? "Extract the greatest common factor!" : "Expand the brackets!", 
            style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(color: AxiomTheme.primaryCyan)),
          const SizedBox(height: 48),
          
          if (!isFactoringMode)
            _buildExpandPhase()
          else
            _buildFactorPhase(),
        ],
      ),
    );
  }

  Widget _buildExpandPhase() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AxiomTheme.primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(multiplier, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 2.seconds),
            const SizedBox(width: 8),
            const Text(" ( ", style: TextStyle(fontSize: 48, color: Colors.white)),
            for (int i = 0; i < termsInside.length; i++) ...[
              GestureDetector(
                onTap: () => _expandTerm(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: termExpanded[i] ? AxiomTheme.accentGold.withOpacity(0.3) : Colors.transparent,
                    border: Border.all(color: termExpanded[i] ? AxiomTheme.accentGold : Colors.grey),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    termExpanded[i] ? expandedResults[i] : termsInside[i],
                    style: TextStyle(fontSize: 28, color: termExpanded[i] ? AxiomTheme.accentGold : Colors.white),
                  ),
                ),
              ),
            ],
            const Text(" ) ", style: TextStyle(fontSize: 48, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 32),
        const Text("Tap the terms inside the brackets to multiply them with the outer factor.", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  Widget _buildFactorPhase() {
    return Column(
      children: [
        Text(factored ? factoredResult : originalExpr, 
          style: TextStyle(fontSize: 48, color: factored ? AxiomTheme.primaryCyan : Colors.white)
        ).animate(target: factored ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.2, 1.2)),
        const SizedBox(height: 48),
        if (!factored)
          Wrap(
            spacing: 16,
            children: factorOptions.map((f) => ElevatedButton(
              onPressed: () => _attemptFactor(f),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                backgroundColor: AxiomTheme.primaryPurple
              ),
              child: Text(f, style: const TextStyle(fontSize: 24, color: Colors.white)),
            )).toList(),
          )
      ],
    );
  }
}
