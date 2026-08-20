import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../models/curriculum.dart';
import '../models/generated_problem.dart';
import '../models/player_profile.dart';
import '../generators/math_generator.dart';
import '../utils/math_parser.dart';
import '../widgets/math_input_toolbar.dart';
import '../widgets/streak_flame_badge.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import 'level_complete_dialog.dart';

class QuestView extends StatefulWidget {
  final Quest quest;

  const QuestView({super.key, required this.quest});

  @override
  State<QuestView> createState() => _QuestViewState();
}

class _QuestViewState extends State<QuestView> {
  DifficultyTier selectedTier = DifficultyTier.makkelijk;
  late GeneratedProblem currentProblem;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int correctInCurrentTier = 0;
  final int targetCorrectPerTier = 4;
  int currentStreak = 0;

  String? feedbackText;
  bool isSuccess = false;
  bool isError = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadNewProblem();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadNewProblem() {
    setState(() {
      currentProblem = QuestionGenerator.generate(
        questId: widget.quest.id,
        tier: selectedTier,
      );
      _inputController.clear();
      feedbackText = null;
      isSuccess = false;
      isError = false;
      isSubmitting = false;
    });
    _focusNode.requestFocus();
  }

  void _submitAnswer() {
    final rawInput = _inputController.text.trim();
    if (rawInput.isEmpty || isSubmitting) return;

    setState(() => isSubmitting = true);

    bool correct = false;
    String feedback = "";

    if (widget.quest.type == QuestType.equations) {
      final res = MathParser.validateEquationAnswer(
        userInput: rawInput,
        variable: currentProblem.variable,
        targetAnswer: currentProblem.targetValue ?? 0,
      );
      correct = res.isValid;
      feedback = res.feedback;
    } else if (widget.quest.type == QuestType.inequality) {
      final res = MathParser.validateInequalityAnswer(
        userInput: rawInput,
        variable: currentProblem.variable,
        expectedOperator: currentProblem.targetOperator ?? '<',
        targetValue: currentProblem.targetValue ?? 0,
      );
      correct = res.isValid;
      feedback = res.feedback;
    } else {
      correct = MathParser.isEquivalent(
        userInput: rawInput,
        canonicalAnswer: currentProblem.canonicalAnswer,
        acceptedAlternatives: currentProblem.acceptedAnswers,
        variable: currentProblem.variable,
      );
      feedback = correct
          ? "🎉 Correct! Uitstekend herleid!"
          : "Nog niet juist. Hint: ${currentProblem.didacticHint}";
    }

    if (correct) {
      SoundEngine().playFusionSound();
      final profile = context.read<PlayerProfile>();
      currentStreak++;

      // Bereken multiplier
      double mult = 1.0;
      if (currentStreak >= 6) {
        mult = 3.0;
      } else if (currentStreak >= 3) {
        mult = 2.0;
      } else if (currentStreak >= 1) {
        mult = 1.5;
      }

      final earnedXP = (widget.quest.baseXP * mult * (selectedTier.index + 1)).round();
      profile.addXP(earnedXP);
      correctInCurrentTier++;

      setState(() {
        isSuccess = true;
        isError = false;
        feedbackText = "$feedback (+$earnedXP XP)";
      });

      if (correctInCurrentTier >= targetCorrectPerTier) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          String nextQuestId = '';
          if (widget.quest.id == 'q1') {
            nextQuestId = 'q2';
          } else if (widget.quest.id == 'q2') {
            nextQuestId = 'q3';
          } else if (widget.quest.id == 'q3') {
            nextQuestId = 'q4';
          }

          LevelCompleteDialog.show(
            context,
            widget.quest,
            3,
            widget.quest.baseXP * (selectedTier.index + 1),
            nextQuestId,
          );
        });
      }
    } else {
      SoundEngine().playErrorSound();
      currentStreak = 0;
      setState(() {
        isSuccess = false;
        isError = true;
        feedbackText = feedback;
      });
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AxiomTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 2,
        title: Text(
          widget.quest.title,
          style: const TextStyle(color: AxiomTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: StreakFlameBadge(streakCount: currentStreak),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                // Niveau Kiezer Tabs
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: DifficultyTier.values.map((tier) {
                      final isSelected = selectedTier == tier;
                      String title;
                      switch (tier) {
                        case DifficultyTier.makkelijk:
                          title = 'Tier 1: Makkelijk';
                          break;
                        case DifficultyTier.gemiddeld:
                          title = 'Tier 2: Gemiddeld';
                          break;
                        case DifficultyTier.vwoMoeilijk:
                          title = 'Tier 3: VWO Niveau';
                          break;
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              if (selectedTier != tier) {
                                SoundEngine().playClickSound();
                                setState(() {
                                  selectedTier = tier;
                                  correctInCurrentTier = 0;
                                  _loadNewProblem();
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AxiomTheme.primaryPurple : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AxiomTheme.accentGold : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: isSelected ? AxiomTheme.textWhite : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Voortgang in Huidig Niveau
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: AxiomTheme.accentGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.quest.tierDescriptions[selectedTier] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        'Score: $correctInCurrentTier / $targetCorrectPerTier',
                        style: const TextStyle(color: AxiomTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Opgave Kaart met KaTeX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF161B22), Color(0xFF0F141C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AxiomTheme.primaryPurple, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AxiomTheme.primaryPurple.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentProblem.instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AxiomTheme.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Math.tex(
                          currentProblem.latexPrompt,
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Feedback Bericht
                if (feedbackText != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? AxiomTheme.primaryCyan.withValues(alpha: 0.15)
                          : AxiomTheme.errorRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSuccess ? AxiomTheme.primaryCyan : AxiomTheme.errorRed),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error_outline,
                          color: isSuccess ? AxiomTheme.primaryCyan : AxiomTheme.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            feedbackText!,
                            style: TextStyle(
                              color: isSuccess ? AxiomTheme.primaryCyan : AxiomTheme.errorRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(duration: isError ? 300.ms : 0.ms),
                  const SizedBox(height: 20),
                ],

                // Invoerveld & Actieknoppen
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              onSubmitted: (_) => _submitAnswer(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.quest.type == QuestType.equations
                                    ? "bijv. ${currentProblem.variable} = 5"
                                    : widget.quest.type == QuestType.inequality
                                        ? "bijv. ${currentProblem.variable} < 3"
                                        : "Typ je herleide antwoord...",
                                hintStyle: const TextStyle(color: Colors.white30, fontSize: 15),
                                filled: true,
                                fillColor: Colors.black45,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AxiomTheme.primaryCyan),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _submitAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AxiomTheme.primaryCyan,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('CONTROLEER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Wiskunde Knoppenbalk
                      MathInputToolbar(
                        controller: _inputController,
                        onSubmitted: _submitAnswer,
                        primaryVariable: currentProblem.variable,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Volgende Som / Nieuwe Generatie Knop
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loadNewProblem,
                      icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                      label: const Text('Nieuwe Opgave Genereren', style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
