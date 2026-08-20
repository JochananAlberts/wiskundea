import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class BalanceGame extends StatefulWidget {
  final Quest quest;
  const BalanceGame({super.key, required this.quest});

  @override
  State<BalanceGame> createState() => _BalanceGameState();
}

class _BalanceGameState extends State<BalanceGame> {
  // Startvergelijking: 5q - 22 = -2q + 54
  // Oplossing: 7q = 76 -> q = 76/7 ≈ 10.857
  double leftQ = 5;
  double leftConst = -22;
  double rightQ = -2;
  double rightConst = 54;

  String operation = '+';
  String inputValue = '2q';
  String statusMessage = "Voer bewerkingen uit op beide zijden om 'q' links te isoleren.";
  bool hasWon = false;

  void _applyOperation(String op, String valStr) {
    if (hasWon) return;

    double qMod = 0;
    double constMod = 0;

    valStr = valStr.trim().replaceAll(' ', '');

    if (valStr.endsWith('q')) {
      final prefix = valStr.substring(0, valStr.length - 1);
      if (prefix.isEmpty || prefix == '+') {
        qMod = 1;
      } else if (prefix == '-') {
        qMod = -1;
      } else {
        qMod = double.tryParse(prefix) ?? 0;
      }
    } else {
      constMod = double.tryParse(valStr) ?? 0;
    }

    setState(() {
      if (op == '+') {
        leftQ += qMod;
        rightQ += qMod;
        leftConst += constMod;
        rightConst += constMod;
      } else if (op == '-') {
        leftQ -= qMod;
        rightQ -= qMod;
        leftConst -= constMod;
        rightConst -= constMod;
      } else if (op == '*') {
        if (constMod != 0) {
          leftQ *= constMod;
          rightQ *= constMod;
          leftConst *= constMod;
          rightConst *= constMod;
        }
      } else if (op == '/' || op == ':') {
        if (constMod != 0) {
          leftQ /= constMod;
          rightQ /= constMod;
          leftConst /= constMod;
          rightConst /= constMod;
        }
      }
    });

    SoundEngine().playClickSound();
    _checkWinCondition();
  }

  void _checkWinCondition() {
    // Winconditie: Links staat precies 1q en 0 constante, rechts staat 0q en de constante (76/7 ≈ 10.857)
    final double diffLeftQ = (leftQ - 1).abs();
    final double diffLeftConst = leftConst.abs();
    final double diffRightQ = rightQ.abs();

    if (diffLeftQ < 0.01 && diffLeftConst < 0.01 && diffRightQ < 0.01) {
      hasWon = true;
      setState(() {
        statusMessage = "🎉 Geweldig! De vergelijking is opgelost: q = ${(rightConst * 100).round() / 100}";
      });
      SoundEngine().playVictoryFanfare();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q4');
      });
    }
  }

  String _formatTex(double q, double c) {
    String res = "";
    if (q.abs() > 0.001) {
      final double roundQ = (q * 100).round() / 100;
      if ((roundQ - 1).abs() < 0.001) {
        res += "q";
      } else if ((roundQ + 1).abs() < 0.001) {
        res += "-q";
      } else {
        res += "${roundQ == roundQ.roundToDouble() ? roundQ.round() : roundQ}q";
      }
    }
    if (c.abs() > 0.001) {
      final double roundC = (c * 100).round() / 100;
      if (res.isNotEmpty) {
        res += roundC > 0
            ? " + ${roundC == roundC.roundToDouble() ? roundC.round() : roundC}"
            : " - ${roundC.abs() == roundC.abs().roundToDouble() ? roundC.abs().round() : roundC.abs()}";
      } else {
        res += "${roundC == roundC.roundToDouble() ? roundC.round() : roundC}";
      }
    }
    if (res.isEmpty) return "0";
    return res;
  }

  void _reset() {
    setState(() {
      leftQ = 5;
      leftConst = -22;
      rightQ = -2;
      rightConst = 54;
      hasWon = false;
      statusMessage = "Vergelijking gereset naar de startpositie.";
    });
    SoundEngine().playClickSound();
  }

  @override
  Widget build(BuildContext context) {
    // Echte waarde van q is 76 / 7 ≈ 10.857
    const double trueQ = 76.0 / 7.0;
    final double leftWeight = leftQ * trueQ + leftConst;
    final double rightWeight = rightQ * trueQ + rightConst;
    final double tilt = ((leftWeight - rightWeight) / 100.0).clamp(-0.25, 0.25);

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
                          "Balansmethode",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Huidige staat: ", style: TextStyle(color: Colors.white70)),
                        Math.tex(
                          "${_formatTex(leftQ, leftConst)} = ${_formatTex(rightQ, rightConst)}",
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: AxiomTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Status indicator
              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 36),

              // Visuele Weegschaal
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Voet
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Pilaar
                    Container(
                      width: 18,
                      height: 140,
                      color: Colors.grey.shade600,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    // Scharnierpunt
                    Container(
                      margin: const EdgeInsets.only(bottom: 145),
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AxiomTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Kantelende balk met schalen
                    Transform.rotate(
                      angle: tilt,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 150),
                        width: 420,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AxiomTheme.accentGold,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPan(_formatTex(leftQ, leftConst), Colors.cyan.shade900),
                            _buildPan(_formatTex(rightQ, rightConst), Colors.purple.shade900),
                          ],
                        ),
                      ),
                    ).animate(target: tilt).rotate(duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Snelle actieknoppen voor veelvoorkomende stappen
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Snelle acties (beide zijden):",
                      style: TextStyle(color: AxiomTheme.accentGold, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildQuickActionButton("+ 2q", () => _applyOperation('+', '2q')),
                        _buildQuickActionButton("+ 22", () => _applyOperation('+', '22')),
                        _buildQuickActionButton(": 7", () => _applyOperation('/', '7')),
                        _buildQuickActionButton("- 54", () => _applyOperation('-', '54')),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    // Aangepaste bewerking invoeren
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        const Text("Zelf bewerking kiezen:", style: TextStyle(color: Colors.white70)),
                        DropdownButton<String>(
                          value: operation,
                          dropdownColor: const Color(0xFF161B22),
                          items: const [
                            DropdownMenuItem(value: '+', child: Text("+ (Optellen)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '-', child: Text("- (Aftrekken)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '*', child: Text("· (Vermenigvuldigen)", style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: '/', child: Text(": (Delen)", style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => operation = v);
                          },
                        ),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            onChanged: (v) => inputValue = v,
                            decoration: InputDecoration(
                              hintText: "bijv. 2q of 22",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyOperation(operation, inputValue),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AxiomTheme.primaryCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text("TOEPASSEN OP BEIDE ZIJDEN", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildQuickActionButton(String label, VoidCallback onPressed) {
    return ActionChip(
      backgroundColor: const Color(0xFF0F141C),
      side: const BorderSide(color: AxiomTheme.primaryCyan),
      label: Text(
        label,
        style: const TextStyle(
          color: AxiomTheme.primaryCyan,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildPan(String tex, Color color) {
    return Transform.translate(
      offset: const Offset(0, 42),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          border: Border.all(color: AxiomTheme.accentGold, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
        ),
        child: Math.tex(
          tex,
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
