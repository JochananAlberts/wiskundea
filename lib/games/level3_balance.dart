import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class BalanceGame extends StatefulWidget {
  final Quest quest;
  const BalanceGame({Key? key, required this.quest}) : super(key: key);

  @override
  _BalanceGameState createState() => _BalanceGameState();
}

class _BalanceGameState extends State<BalanceGame> {
  // Equation: 5q - 22 = -2q + 54
  double leftQ = 5;
  double leftConst = -22;
  double rightQ = -2;
  double rightConst = 54;

  String operation = '+';
  String inputValue = '2q';

  void _applyOperation() {
    double qMod = 0;
    double constMod = 0;
    
    if (inputValue.endsWith('q')) {
      qMod = double.tryParse(inputValue.replaceAll('q', '')) ?? 1;
      if (inputValue == 'q') qMod = 1;
      if (inputValue == '-q') qMod = -1;
    } else {
      constMod = double.tryParse(inputValue) ?? 0;
    }

    setState(() {
      if (operation == '+') {
        leftQ += qMod; rightQ += qMod;
        leftConst += constMod; rightConst += constMod;
      } else if (operation == '-') {
        leftQ -= qMod; rightQ -= qMod;
        leftConst -= constMod; rightConst -= constMod;
      } else if (operation == '*') {
        if (constMod != 0) {
          leftQ *= constMod; rightQ *= constMod;
          leftConst *= constMod; rightConst *= constMod;
        }
      } else if (operation == '/') {
        if (constMod != 0) {
          leftQ /= constMod; rightQ /= constMod;
          leftConst /= constMod; rightConst /= constMod;
        }
      }
    });

    SoundEngine().playClickSound();
    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (leftQ == 1 && leftConst == 0 && rightQ == 0) {
      SoundEngine().playFusionSound();
      Future.delayed(const Duration(milliseconds: 500), () {
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q4');
      });
    }
  }

  String _formatSide(double q, double c) {
    String res = "";
    if (q != 0) {
      if (q == 1) res += "q";
      else if (q == -1) res += "-q";
      else res += "${q == q.roundToDouble() ? q.round() : q}q";
    }
    if (c != 0) {
      if (res.isNotEmpty) {
        res += c > 0 ? " + ${c == c.roundToDouble() ? c.round() : c}" : " - ${c.abs() == c.abs().roundToDouble() ? c.abs().round() : c.abs()}";
      } else {
        res += "${c == c.roundToDouble() ? c.round() : c}";
      }
    }
    if (res.isEmpty) return "0";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    // Basic tilt calculation based on q value of 10.857
    double trueQ = (54 + 22) / (5 + 2); // 10.857
    double leftWeight = leftQ * trueQ + leftConst;
    double rightWeight = rightQ * trueQ + rightConst;
    double tilt = (leftWeight - rightWeight).clamp(-50, 50) / 100.0; // -0.5 to 0.5

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text("Balance the scale to find 'q'", style: AxiomTheme.themeData.textTheme.displayMedium),
          const SizedBox(height: 48),
          
          // Visual Scale
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Base
              Container(width: 100, height: 20, color: Colors.grey.shade700),
              // Pillar
              Container(width: 20, height: 150, color: Colors.grey.shade600, margin: const EdgeInsets.only(bottom: 20)),
              // Beam
              Transform.rotate(
                angle: tilt,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 150),
                  width: 300, height: 10, color: AxiomTheme.accentGold,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPan(_formatSide(leftQ, leftConst)),
                      _buildPan(_formatSide(rightQ, rightConst)),
                    ],
                  ),
                ),
              ).animate(target: tilt).rotate(duration: 500.ms, curve: Curves.easeInOut),
            ],
          ),
          
          const SizedBox(height: 64),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AxiomTheme.themeData.cardTheme.color,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: operation,
                  dropdownColor: AxiomTheme.background,
                  items: ['+', '-', '*', '/'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 24, color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => operation = v!),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: TextField(
                    onChanged: (v) => inputValue = v,
                    decoration: const InputDecoration(
                      hintText: "e.g. 2q or 22",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.black26
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _applyOperation,
                  child: const Text("APPLY TO BOTH SIDES"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPan(String text) {
    return Transform.translate(
      offset: const Offset(0, 30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AxiomTheme.primaryPurple,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
