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
  int targetScore = 4;
  int? selectedTileIndex;
  String feedbackMessage = "Tik op een tegel om te selecteren, of sleep twee tegels op elkaar!";
  bool isError = false;
  String lastFormulaTex = r'3x + 2x = 5x';

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    grid = [
      Term(3, 'x', 1), Term(2, 'x', 1), Term(4, 'x', 2),
      Term(5, 'x', 2), Term(2, 'a', 3), Term(3, 'a', 3),
      Term(6, 'x', 1), Term(4, 'a', 3), Term(2, 'x', 2),
    ];
    score = 0;
    selectedTileIndex = null;
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

  void _mergeTiles(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) {
      setState(() => selectedTileIndex = null);
      return;
    }
    final fromTerm = grid[fromIndex];
    final toTerm = grid[toIndex];

    if (fromTerm == null) {
      setState(() => selectedTileIndex = null);
      return;
    }

    setState(() {
      if (toTerm == null) {
        // Verplaatsen
        grid[toIndex] = fromTerm;
        grid[fromIndex] = null;
        selectedTileIndex = null;
        SoundEngine().playClickSound();
        feedbackMessage = "Tegel verplaatst.";
        isError = false;
      } else {
        // Probeer samenvoegen
        if (_canFuse(fromTerm, toTerm)) {
          final result = _fuse(fromTerm, toTerm);
          if (isMultiplication) {
            lastFormulaTex = "${fromTerm.tex} \\cdot ${toTerm.tex} = ${result.tex}";
            feedbackMessage = "Machten vermenigvuldigd: exponenten opgeteld!";
          } else {
            lastFormulaTex = "${fromTerm.tex} + ${toTerm.tex} = ${result.tex}";
            feedbackMessage = "Gelijksoortige termen herleid: coëfficiënten opgeteld!";
          }
          grid[toIndex] = result;
          grid[fromIndex] = null;
          selectedTileIndex = null;
          score++;
          isError = false;
          SoundEngine().playFusionSound();

          if (score >= targetScore) {
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q2');
            });
          }
        } else {
          SoundEngine().playErrorSound();
          isError = true;
          selectedTileIndex = null;
          if (isMultiplication) {
            feedbackMessage = "Fout: Alleen termen met dezelfde variabele (${fromTerm.variable} ≠ ${toTerm.variable}) kunnen worden vermenigvuldigd!";
          } else {
            feedbackMessage = "Fout: Je kunt alleen gelijksoortige termen optellen (gelijke variabele én exponent)!";
          }
        }
      }
    });
  }

  void _handleTapTile(int index) {
    if (selectedTileIndex == null) {
      if (grid[index] != null) {
        setState(() {
          selectedTileIndex = index;
          SoundEngine().playClickSound();
          feedbackMessage = "Tegel geselecteerd: ${grid[index]!.tex}. Tik nu op een andere tegel om te combineren.";
          isError = false;
        });
      }
    } else {
      _mergeTiles(selectedTileIndex!, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              // Uitleg & Modus selector
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
                              isMultiplication ? "Machten vermenigvuldigen (·)" : "Gelijksoortige termen optellen (+)",
                              style: const TextStyle(
                                color: AxiomTheme.primaryCyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: isMultiplication,
                              activeThumbColor: AxiomTheme.accentGold,
                              onChanged: (val) {
                                setState(() {
                                  isMultiplication = val;
                                  selectedTileIndex = null;
                                  isError = false;
                                  feedbackMessage = isMultiplication
                                      ? "Modus: Vermenigvuldigen (Regel: a^p · a^q = a^{p+q})"
                                      : "Modus: Optellen (Herleiden: 3x + 2x = 5x)";
                                });
                                SoundEngine().playClickSound();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Laatste bewerking: ", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Math.tex(
                              lastFormulaTex,
                              textStyle: const TextStyle(
                                color: AxiomTheme.accentGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Doel: $score / $targetScore fusies",
                          style: const TextStyle(
                            color: AxiomTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Feedback banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate(key: ValueKey(feedbackMessage)).fadeIn(),

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
                      final term = grid[index];
                      final isSelected = selectedTileIndex == index;

                      return DragTarget<int>(
                        onAcceptWithDetails: (details) => _mergeTiles(details.data, index),
                        builder: (ctx, candidateData, rejectedData) {
                          return GestureDetector(
                            onTap: () => _handleTapTile(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AxiomTheme.accentGold.withValues(alpha: 0.25)
                                    : candidateData.isNotEmpty
                                        ? AxiomTheme.primaryCyan.withValues(alpha: 0.25)
                                        : const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AxiomTheme.accentGold
                                      : candidateData.isNotEmpty
                                          ? AxiomTheme.primaryCyan
                                          : AxiomTheme.primaryPurple.withValues(alpha: 0.4),
                                  width: isSelected || candidateData.isNotEmpty ? 2.5 : 1.5,
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
                                      child: _buildTile(term.tex, isSelected: isSelected),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _initGrid());
                      SoundEngine().playClickSound();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                    label: const Text("Speelveld opnieuw laden", style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "💡 Tip: Je kunt zowel slepen (drag & drop) als twee tegels achter elkaar aantikken om te combineren.",
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String tex, {bool isDragging = false, bool isSelected = false}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSelected
                ? const Color(0xFF8A6D00)
                : isDragging
                    ? AxiomTheme.primaryPurple
                    : AxiomTheme.primaryPurple.withValues(alpha: 0.8),
            const Color(0xFF381263),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AxiomTheme.accentGold.withValues(alpha: 0.6)
                : AxiomTheme.primaryPurple.withValues(alpha: isDragging ? 0.8 : 0.3),
            blurRadius: isSelected || isDragging ? 16 : 8,
            spreadRadius: isSelected || isDragging ? 2 : 0,
          )
        ],
      ),
      alignment: Alignment.center,
      child: Math.tex(
        tex,
        textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isSelected ? AxiomTheme.accentGold : AxiomTheme.textWhite,
        ),
      ),
    );
  }
}
