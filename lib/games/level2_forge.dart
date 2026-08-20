import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class ForgeGame extends StatefulWidget {
  final Quest quest;
  const ForgeGame({super.key, required this.quest});

  @override
  State<ForgeGame> createState() => _ForgeGameState();
}

class _ForgeGameState extends State<ForgeGame> {
  // Fase 1: Haakjes wegwerken -> 3a(2a - 5b)
  final String factorOutside = "3a";
  final List<String> insideTerms = ["2a", "-5b"];
  final List<bool> termsExpanded = [false, false];
  final List<String> expandedTermsTex = [r"6a^2", r"-15ab"];

  bool isFactoringMode = false; // Fase 2: Ontbinden in factoren

  // Fase 2: Ontbinden in factoren -> 6p^2 - 10pq
  final String originalExprTex = r"6p^2 - 10pq";
  final List<String> factorOptionsTex = [r"2", r"p", r"2p", r"3p", r"6p"];
  final String correctFactorTex = r"2p";
  final String factoredResultTex = r"2p(3p - 5q)";
  bool isFactored = false;
  String? wrongAttempt;

  void _expandTerm(int index) {
    if (!termsExpanded[index]) {
      setState(() {
        termsExpanded[index] = true;
      });
      SoundEngine().playFusionSound();

      if (termsExpanded.every((e) => e == true)) {
        // Na 1 seconde door naar fase 2
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            isFactoringMode = true;
          });
          SoundEngine().playClickSound();
        });
      }
    }
  }

  void _attemptFactor(String factorTex) {
    if (factorTex == correctFactorTex) {
      setState(() {
        isFactored = true;
        wrongAttempt = null;
      });
      SoundEngine().playFusionSound();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q3');
      });
    } else {
      SoundEngine().playErrorSound();
      setState(() {
        wrongAttempt = factorTex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Voortgangsbalk & Titel
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFactoringMode
                          ? "Fase 2 van 2: Ontbinden in Factoren"
                          : "Fase 1 van 2: Haakjes Wegwerken",
                      style: const TextStyle(
                        color: AxiomTheme.accentGold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AxiomTheme.primaryCyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isFactoringMode ? "Grootste factor (ggd)" : "Distributieve wet",
                        style: const TextStyle(
                          color: AxiomTheme.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              if (!isFactoringMode) _buildExpandPhase() else _buildFactorPhase(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandPhase() {
    return Column(
      children: [
        Text(
          "Haakjes Wegwerken",
          style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
            fontSize: 26,
            color: AxiomTheme.primaryCyan,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Vermenigvuldig de factor vóór de haakjes met elke afzonderlijke term binnen de haakjes.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 36),

        // Interactieve formule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AxiomTheme.primaryPurple, width: 2),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 16,
            children: [
              // Factor buiten haakjes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AxiomTheme.primaryPurple, Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AxiomTheme.primaryPurple.withValues(alpha: 0.5),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Math.tex(
                  factorOutside,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds),

              const Text(
                "(",
                style: TextStyle(fontSize: 38, color: Colors.white70, fontWeight: FontWeight.w300),
              ),

              // Termen binnen haakjes
              for (int i = 0; i < insideTerms.length; i++) ...[
                if (i > 0 && !termsExpanded[i] && !insideTerms[i].startsWith('-'))
                  const Text("+", style: TextStyle(fontSize: 24, color: Colors.white70)),
                GestureDetector(
                  onTap: () => _expandTerm(i),
                  child: MouseRegion(
                    cursor: termsExpanded[i]
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: termsExpanded[i]
                            ? AxiomTheme.accentGold.withValues(alpha: 0.2)
                            : const Color(0xFF161B22),
                        border: Border.all(
                          color: termsExpanded[i] ? AxiomTheme.accentGold : Colors.white24,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: termsExpanded[i]
                            ? [
                                BoxShadow(
                                  color: AxiomTheme.accentGold.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ]
                            : [],
                      ),
                      child: Math.tex(
                        termsExpanded[i] ? expandedTermsTex[i] : insideTerms[i],
                        textStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: termsExpanded[i] ? AxiomTheme.accentGold : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const Text(
                ")",
                style: TextStyle(fontSize: 38, color: Colors.white70, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            termsExpanded.every((e) => e)
                ? "✨ Voltooid! Resultaat: 6a² - 15ab. Nu door naar ontbinden..."
                : "👉 Klik op elke term binnen de haakjes om te vermenigvuldigen.",
            style: TextStyle(
              color: termsExpanded.every((e) => e) ? AxiomTheme.accentGold : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFactorPhase() {
    return Column(
      children: [
        Text(
          "Ontbinden in Factoren",
          style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
            fontSize: 26,
            color: AxiomTheme.primaryCyan,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Zoek de grootste gemeenschappelijke factor van beide termen en haal deze buiten haakjes.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 36),

        // Grote LaTeX weergave
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFactored ? AxiomTheme.primaryCyan : AxiomTheme.primaryPurple,
              width: 2,
            ),
          ),
          child: Math.tex(
            isFactored ? factoredResultTex : originalExprTex,
            textStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isFactored ? AxiomTheme.primaryCyan : Colors.white,
            ),
          ),
        ).animate(target: isFactored ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 400.ms,
            ),

        const SizedBox(height: 36),
        if (!isFactored) ...[
          const Text(
            "Welke factor kan maximaal buiten haakjes worden gehaald?",
            style: TextStyle(color: AxiomTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: factorOptionsTex.map((f) {
              final isWrong = wrongAttempt == f;
              return ElevatedButton(
                onPressed: () => _attemptFactor(f),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  backgroundColor: isWrong ? AxiomTheme.errorRed : const Color(0xFF161B22),
                  side: BorderSide(
                    color: isWrong ? AxiomTheme.errorRed : AxiomTheme.primaryPurple,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Math.tex(
                  f,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          if (wrongAttempt != null) ...[
            const SizedBox(height: 16),
            const Text(
              "Niet de grootste factor! Kijk naar de getallen (ggd van 6 en 10 is 2) én de letters (p² en p).",
              textAlign: TextAlign.center,
              style: TextStyle(color: AxiomTheme.errorRed, fontSize: 14, fontWeight: FontWeight.bold),
            ).animate().shake(),
          ],
        ] else ...[
          const Text(
            "🎉 Uitstekend! 6p² - 10pq = 2p(3p - 5q)",
            style: TextStyle(color: AxiomTheme.primaryCyan, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
