import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' show pi;
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class InequalityGame extends StatefulWidget {
  final Quest quest;
  const InequalityGame({super.key, required this.quest});

  @override
  State<InequalityGame> createState() => _InequalityGameState();
}

class _InequalityGameState extends State<InequalityGame> {
  // Startongelijkheid: -5t > -15
  // Oplossing: delen door -5 -> t < 3
  double tCoeff = -5;
  String operator = '>';
  double constant = -15;

  String actionOp = '/';
  String inputValue = '-5';

  bool _isFlipped = false;
  String feedbackMessage = "Isoleer 't'. Pas op bij delen door een negatief getal!";
  bool hasWon = false;

  void _applyOperation(String op, String valStr) {
    if (hasWon) return;

    final double? val = double.tryParse(valStr.trim());
    if (val == null || (val == 0 && op == '/')) {
      SoundEngine().playErrorSound();
      setState(() {
        feedbackMessage = "Ongeldige invoer of delen door 0!";
      });
      return;
    }

    setState(() {
      if (op == '+') {
        constant += val;
      } else if (op == '-') {
        constant -= val;
      } else if (op == '*') {
        tCoeff *= val;
        constant *= val;
        if (val < 0) _flipOperator();
      } else if (op == '/') {
        tCoeff /= val;
        constant /= val;
        if (val < 0) _flipOperator();
      }
    });

    SoundEngine().playClickSound();
    _checkWinCondition();
  }

  void _flipOperator() {
    SoundEngine().playFlipSound();
    _isFlipped = !_isFlipped;
    if (operator == '>') {
      operator = '<';
    } else if (operator == '<') {
      operator = '>';
    } else if (operator == r'\ge' || operator == '>=') {
      operator = r'\le';
    } else if (operator == r'\le' || operator == '<=') {
      operator = r'\ge';
    }

    feedbackMessage = "🔄 Dimensie Klap! Gedeeld/vermenigvuldigd met een negatief getal: het teken klapt om!";
  }

  void _checkWinCondition() {
    // t < 3
    final bool isCorrectCoeff = (tCoeff - 1).abs() < 0.01;
    final bool isCorrectConst = (constant - 3).abs() < 0.01;
    final bool isCorrectOp = operator == '<';

    if (isCorrectCoeff && isCorrectConst && isCorrectOp) {
      hasWon = true;
      setState(() {
        feedbackMessage = "🎉 Perfect! De ongelijkheid is opgelost: t < 3";
      });
      SoundEngine().playVictoryFanfare();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, '');
      });
    }
  }

  String _formatTexLeft(double val) {
    final double r = (val * 100).round() / 100;
    if ((r - 1).abs() < 0.001) return "t";
    if ((r + 1).abs() < 0.001) return "-t";
    return "${r == r.roundToDouble() ? r.round() : r}t";
  }

  String _formatTexRight(double val) {
    final double r = (val * 100).round() / 100;
    return "${r == r.roundToDouble() ? r.round() : r}";
  }

  void _reset() {
    setState(() {
      tCoeff = -5;
      operator = '>';
      constant = -15;
      _isFlipped = false;
      hasWon = false;
      feedbackMessage = "Ongelijkheid gereset naar de beginwaarde.";
    });
    SoundEngine().playClickSound();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Uitlegbalk
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
                          "Ongelijkheden & Mintekenregel",
                          style: TextStyle(
                            color: AxiomTheme.accentGold,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                          label: const Text("Reset", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Onthoud: Delen of vermenigvuldigen met een negatief getal draait het teken om (> wordt <).",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Feedback banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AxiomTheme.primaryCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AxiomTheme.primaryCyan),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: AxiomTheme.primaryCyan, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        feedbackMessage,
                        style: const TextStyle(
                          color: AxiomTheme.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate(key: ValueKey(feedbackMessage)).fadeIn(),

              const SizedBox(height: 36),

              // 3D Flipped KaTeX Box
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutBack,
                builder: (context, double val, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(val),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AxiomTheme.primaryPurple, Color(0xFF4A148C)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AxiomTheme.accentGold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AxiomTheme.primaryCyan.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Transform(
                        alignment: Alignment.center,
                        // Spiegel de tekst weer recht als de kaart omgedraaid is
                        transform: Matrix4.identity()..rotateY(val >= pi / 2 ? pi : 0),
                        child: Math.tex(
                          "${_formatTexLeft(tCoeff)} $operator ${_formatTexRight(constant)}",
                          textStyle: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // Bediening
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Snelle actie:",
                      style: TextStyle(color: AxiomTheme.accentGold, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ActionChip(
                      backgroundColor: const Color(0xFF0F141C),
                      side: const BorderSide(color: AxiomTheme.primaryCyan),
                      label: const Text(
                        "Deel beide kanten door -5  (: -5)",
                        style: TextStyle(
                          color: AxiomTheme.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _applyOperation('/', '-5'),
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        const Text("Of kies een bewerking:", style: TextStyle(color: Colors.white70)),
                        DropdownButton<String>(
                          value: actionOp,
                          dropdownColor: const Color(0xFF161B22),
                          items: const [
                            DropdownMenuItem(value: '+', child: Text("+ (Optellen)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '-', child: Text("- (Aftrekken)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '*', child: Text("· (Vermenigvuldigen)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '/', child: Text(": (Delen)", style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => actionOp = v);
                          },
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            onChanged: (v) => inputValue = v,
                            controller: TextEditingController(text: inputValue)
                              ..selection = TextSelection.collapsed(offset: inputValue.length),
                            decoration: InputDecoration(
                              hintText: "-5",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyOperation(actionOp, inputValue),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AxiomTheme.primaryCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          child: const Text("TOEPASSEN", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
