import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class Term {
  int coeff;
  String variable;
  int exponent;

  Term(this.coeff, this.variable, this.exponent);

  String get tex {
    if (coeff == 0) return '0';
    String c;
    if (coeff == 1 && variable.isNotEmpty) {
      c = '';
    } else if (coeff == -1 && variable.isNotEmpty) {
      c = '-';
    } else {
      c = coeff.toString();
    }
    String v = variable;
    String e = exponent > 1 ? '^{$exponent}' : '';
    if (variable.isEmpty) return coeff.toString();
    return '$c$v$e';
  }
}

class FusionGame extends StatefulWidget {
  final Quest quest;
  const FusionGame({super.key, required this.quest});

  @override
  State<FusionGame> createState() => _FusionGameState();
}

class _FusionGameState extends State<FusionGame> {
  List<Term?> grid = [];
  bool isMultiplication = false;
  int score = 0;
  int targetScore = 3;
  String feedbackMessage = "Sleep en combineer termen die bij elkaar passen!";
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    grid = [
      Term(3, 'x', 1), Term(2, 'x', 1), Term(4, 'x', 2),
      Term(5, 'x', 2), Term(2, 'a', 3), Term(3, 'a', 3),
      Term(6, 'x', 1), Term(4, 'a', 3), null,
    ];
  }

  bool _canFuse(Term a, Term b) {
    if (isMultiplication) {
      return a.variable == b.variable; // Machten vermenigvuldigen bij gelijk grondtal
    } else {
      return a.variable == b.variable && a.exponent == b.exponent; // Gelijksoortige termen optellen
    }
  }

  Term _fuse(Term a, Term b) {
    if (isMultiplication) {
      return Term(a.coeff * b.coeff, a.variable, a.exponent + b.exponent);
    } else {
      return Term(a.coeff + b.coeff, a.variable, a.exponent);
    }
  }

  void _handleDrop(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    final fromTerm = grid[fromIndex];
    final toTerm = grid[toIndex];

    if (fromTerm == null) return;

    setState(() {
      if (toTerm == null) {
        // Alleen verplaatsen
        grid[toIndex] = fromTerm;
        grid[fromIndex] = null;
        SoundEngine().playClickSound();
      } else {
        // Poging tot fuseren
        if (_canFuse(fromTerm, toTerm)) {
          final result = _fuse(fromTerm, toTerm);
          grid[toIndex] = result;
          grid[fromIndex] = null;
          SoundEngine().playFusionSound();
          score++;
          isError = false;
          if (isMultiplication) {
            feedbackMessage = "Machten vermenigvuldigd: exponenten opgeteld!";
          } else {
            feedbackMessage = "Gelijksoortige termen herleid: coëfficiënten opgeteld!";
          }

          if (score >= targetScore) {
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q2');
            });
          }
        } else {
          SoundEngine().playErrorSound();
          isError = true;
          if (isMultiplication) {
            feedbackMessage = "Fout: Alleen termen met dezelfde variabele kunnen worden vermenigvuldigd!";
          } else {
            feedbackMessage = "Fout: Je kunt alleen gelijksoortige termen optellen (gelijke variabele én exponent)!";
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Uitlegkaart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bewerkingsmodus:",
                          style: TextStyle(
                            color: AxiomTheme.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isMultiplication ? "Vermenigvuldigen (·)" : "Optellen (+)",
                              style: const TextStyle(
                                color: AxiomTheme.primaryCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: isMultiplication,
                              activeThumbColor: AxiomTheme.accentGold,
                              onChanged: (val) {
                                setState(() {
                                  isMultiplication = val;
                                  isError = false;
                                  feedbackMessage = isMultiplication
                                      ? "Modus: Vermenigvuldigen (Machtenregel: a^p · a^q = a^{p+q})"
                                      : "Modus: Optellen (Herleiden: 3x + 2x = 5x)";
                                });
                                SoundEngine().playClickSound();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Regel: ", style: TextStyle(color: Colors.white70)),
                            Math.tex(
                              isMultiplication
                                  ? r'4x^3 \cdot 2x^2 = 8x^5'
                                  : r'3x + 2x = 5x',
                              textStyle: const TextStyle(
                                color: AxiomTheme.accentGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Voortgang: $score / $targetScore",
                          style: const TextStyle(
                            color: AxiomTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Feedback banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isError
                      ? AxiomTheme.errorRed.withValues(alpha: 0.2)
                      : AxiomTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isError ? AxiomTheme.errorRed : AxiomTheme.primaryCyan,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isError ? Icons.cancel : Icons.lightbulb,
                      color: isError ? AxiomTheme.errorRed : AxiomTheme.primaryCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        feedbackMessage,
                        style: TextStyle(
                          color: isError ? AxiomTheme.errorRed : AxiomTheme.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate(key: ValueKey(feedbackMessage)).fadeIn().shake(duration: 300.ms),

              const SizedBox(height: 24),

              // Grid Speelveld
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F141C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AxiomTheme.primaryPurple, width: 2),
                ),
                child: SizedBox(
                  width: 360,
                  height: 360,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 9,
                    itemBuilder: (ctx, index) {
                      return DragTarget<int>(
                        onAcceptWithDetails: (details) => _handleDrop(details.data, index),
                        builder: (ctx, candidateData, rejectedData) {
                          final term = grid[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: candidateData.isNotEmpty
                                  ? AxiomTheme.primaryCyan.withValues(alpha: 0.25)
                                  : const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: candidateData.isNotEmpty
                                    ? AxiomTheme.primaryCyan
                                    : AxiomTheme.primaryPurple.withValues(alpha: 0.4),
                                width: candidateData.isNotEmpty ? 2.5 : 1.5,
                              ),
                            ),
                            child: term == null
                                ? null
                                : Draggable<int>(
                                    data: index,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: _buildTile(term.tex, isDragging: true),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.25,
                                      child: _buildTile(term.tex),
                                    ),
                                    child: _buildTile(term.tex),
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "💡 Tip: Sleep een tegel bovenop een andere om ze te fuseren.",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String tex, {bool isDragging = false}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDragging
                ? AxiomTheme.primaryPurple
                : AxiomTheme.primaryPurple.withValues(alpha: 0.8),
            const Color(0xFF381263),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AxiomTheme.primaryPurple.withValues(alpha: isDragging ? 0.8 : 0.3),
            blurRadius: isDragging ? 16 : 8,
            spreadRadius: isDragging ? 2 : 0,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Math.tex(
        tex,
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AxiomTheme.textWhite,
        ),
      ),
    );
  }
}
