import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class ExpandProblem {
  final String factorOutside;
  final List<String> insideTerms;
  final List<String> expandedTermsTex;
  final String finalTex;

  ExpandProblem({
    required this.factorOutside,
    required this.insideTerms,
    required this.expandedTermsTex,
    required this.finalTex,
  });
}

class FactorProblem {
  final String originalExprTex;
  final List<String> optionsTex;
  final String correctFactorTex;
  final String factoredResultTex;

  FactorProblem({
    required this.originalExprTex,
    required this.optionsTex,
    required this.correctFactorTex,
    required this.factoredResultTex,
  });
}

class ForgeGame extends StatefulWidget {
  final Quest quest;
  const ForgeGame({super.key, required this.quest});

  @override
  State<ForgeGame> createState() => _ForgeGameState();
}

class _ForgeGameState extends State<ForgeGame> {
  final List<ExpandProblem> expandProblems = [
    ExpandProblem(
      factorOutside: "3a",
      insideTerms: ["2a", "-5b"],
      expandedTermsTex: [r"6a^2", r"-15ab"],
      finalTex: r"6a^2 - 15ab",
    ),
    ExpandProblem(
      factorOutside: "-4x",
      insideTerms: ["3x", "+2y"],
      expandedTermsTex: [r"-12x^2", r"-8xy"],
      finalTex: r"-12x^2 - 8xy",
    ),
  ];

  final List<FactorProblem> factorProblems = [
    FactorProblem(
      originalExprTex: r"6p^2 - 10pq",
      optionsTex: [r"2", r"p", r"2p", r"3p", r"6p"],
      correctFactorTex: r"2p",
      factoredResultTex: r"2p(3p - 5q)",
    ),
    FactorProblem(
      originalExprTex: r"15x^3 + 25x^2",
      optionsTex: [r"5", r"5x", r"5x^2", r"15x^2", r"25x"],
      correctFactorTex: r"5x^2",
      factoredResultTex: r"5x^2(3x + 5)",
    ),
  ];

  int currentStage = 0;
  List<bool> termsExpanded = [];
  bool isFactored = false;
  String? wrongAttempt;

  @override
  void initState() {
    super.initState();
    _initStage();
  }

  void _initStage() {
    if (currentStage < expandProblems.length) {
      termsExpanded = List.filled(expandProblems[currentStage].insideTerms.length, false);
    } else {
      isFactored = false;
      wrongAttempt = null;
    }
  }

  void _expandTerm(int index) {
    if (!termsExpanded[index]) {
      setState(() {
        termsExpanded[index] = true;
      });
      SoundEngine().playFusionSound();

      if (termsExpanded.every((e) => e == true)) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          _nextStage();
        });
      }
    }
  }

  void _attemptFactor(String factorTex) {
    final problem = factorProblems[currentStage - expandProblems.length];
    if (factorTex == problem.correctFactorTex) {
      setState(() {
        isFactored = true;
        wrongAttempt = null;
      });
      SoundEngine().playFusionSound();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _nextStage();
      });
    } else {
      SoundEngine().playErrorSound();
      setState(() {
        wrongAttempt = factorTex;
      });
    }
  }

  void _nextStage() {
    if (currentStage < expandProblems.length + factorProblems.length - 1) {
      setState(() {
        currentStage++;
        _initStage();
      });
      SoundEngine().playClickSound();
    } else {
      LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q2');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpand = currentStage < expandProblems.length;
    final int totalStages = expandProblems.length + factorProblems.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              // Voortgang
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
                      "Opgave ${currentStage + 1} van $totalStages: ${isExpand ? 'Haakjes Wegwerken' : 'Ontbinden in Factoren'}",
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
                        isExpand ? "Distributiviteit" : "GGD buiten haakjes",
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

              if (isExpand) _buildExpandPhase() else _buildFactorPhase(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandPhase() {
    final problem = expandProblems[currentStage];

    return Column(
      children: [
        Text(
          "Haakjes Wegwerken",
          style: AxiomTheme.themeData.textTheme.displayMedium?.copyWith(
            fontSize: 26,
            color: AxiomTheme.primaryCyan,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Klik op elke term binnen de haakjes om de vermenigvuldiging uit te voeren.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 36),

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
                  problem.factorOutside,
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

              for (int i = 0; i < problem.insideTerms.length; i++) ...[
                if (i > 0 && !termsExpanded[i] && !problem.insideTerms[i].startsWith('-'))
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
                        termsExpanded[i] ? problem.expandedTermsTex[i] : problem.insideTerms[i],
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
                ? "Opgelost: ${problem.finalTex}"
                : "Klik op elke term binnen de haakjes om te vermenigvuldigen.",
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
    final problem = factorProblems[currentStage - expandProblems.length];

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
          "Kies de juiste factor om buiten haakjes te halen.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 36),

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
            isFactored ? problem.factoredResultTex : problem.originalExprTex,
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
            "Welke factor hoort buiten de haakjes?",
            style: TextStyle(color: AxiomTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: problem.optionsTex.map((f) {
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
              "Fout antwoord. Probeer het opnieuw.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AxiomTheme.errorRed, fontSize: 14, fontWeight: FontWeight.bold),
            ).animate().shake(),
          ],
        ] else ...[
          Text(
            "Correct: ${problem.originalExprTex} = ${problem.factoredResultTex}",
            style: const TextStyle(color: AxiomTheme.primaryCyan, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
