import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' show pi;
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class InequalityGame extends StatefulWidget {
  final Quest quest;
  const InequalityGame({Key? key, required this.quest}) : super(key: key);

  @override
  _InequalityGameState createState() => _InequalityGameState();
}

class _InequalityGameState extends State<InequalityGame> {
  // Equation: -5t > -15
  double tCoeff = -5;
  String operator = '>';
  double constant = -15;

  String actionOp = '/';
  String inputValue = '-5';
  
  bool _isFlipped = false;

  void _applyOperation() {
    double val = double.tryParse(inputValue) ?? 1;
    if (val == 0 && (actionOp == '/')) {
      SoundEngine().playErrorSound();
      return;
    }

    setState(() {
      if (actionOp == '+') {
        constant += val;
      } else if (actionOp == '-') {
        constant -= val;
      } else if (actionOp == '*') {
        tCoeff *= val;
        constant *= val;
        if (val < 0) _flipOperator();
      } else if (actionOp == '/') {
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
    if (operator == '>') operator = '<';
    else if (operator == '<') operator = '>';
    else if (operator == '>=') operator = '<=';
    else if (operator == '<=') operator = '>=';
  }

  void _checkWinCondition() {
    if (tCoeff == 1 && constant == 3 && operator == '<') {
      SoundEngine().playVictoryFanfare();
      Future.delayed(const Duration(milliseconds: 500), () {
        LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, '');
      });
    }
  }

  String _formatSide(double val, bool isVariable) {
    if (val == val.roundToDouble()) {
      int v = val.round();
      if (isVariable) {
        if (v == 1) return "t";
        if (v == -1) return "-t";
        return "${v}t";
      }
      return v.toString();
    }
    return isVariable ? "${val}t" : val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Isolate 't'. Watch out for negative multiplication/division!", 
            style: AxiomTheme.themeData.textTheme.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 64),
          
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
            duration: const Duration(milliseconds: 600),
            builder: (context, double val, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(val),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AxiomTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AxiomTheme.primaryCyan.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)
                    ]
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    // Re-flip text so it is readable after card flip
                    transform: Matrix4.identity()..rotateY(val >= pi/2 ? pi : 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatSide(tCoeff, true), style: const TextStyle(fontSize: 64, color: Colors.white)),
                        const SizedBox(width: 24),
                        Text(operator, style: const TextStyle(fontSize: 64, color: AxiomTheme.accentGold)),
                        const SizedBox(width: 24),
                        Text(_formatSide(constant, false), style: const TextStyle(fontSize: 64, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 64),
          
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
                  value: actionOp,
                  dropdownColor: AxiomTheme.background,
                  items: ['+', '-', '*', '/'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 24, color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => actionOp = v!),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    onChanged: (v) => inputValue = v,
                    controller: TextEditingController(text: inputValue)..selection = TextSelection.collapsed(offset: inputValue.length),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.black26
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _applyOperation,
                  child: const Text("APPLY"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
