import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' show pi;
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class InequalityProblem {
  final String variable;
  final double startCoeff;
  final String startOperator;
  final double startConst;
  final double targetConst;
  final String targetOperator;
  final List<String> recommendedSteps;

  InequalityProblem({
    required this.variable,
    required this.startCoeff,
    required this.startOperator,
    required this.startConst,
    required this.targetConst,
    required this.targetOperator,
    required this.recommendedSteps,
  });
}

class InequalityGame extends StatefulWidget {
  final Quest quest;
  const InequalityGame({super.key, required this.quest});

  @override
  State<InequalityGame> createState() => _InequalityGameState();
}

class _InequalityGameState extends State<InequalityGame> {
  // 3 progressive ongelijkheden
  final List<InequalityProblem> problems = [
    InequalityProblem(
      variable: 't',
      startCoeff: -5,
      startOperator: '>',
      startConst: -15,
      targetConst: 3,
      targetOperator: '<', // -5t > -15 -> t < 3
      recommendedSteps: [': -5'],
    ),
    InequalityProblem(
      variable: 'x',
      startCoeff: -2,
      startOperator: r'\le',
      startConst: 12,
      targetConst: -6,
      targetOperator: r'\ge', // -2x <= 12 -> x >= -6
      recommendedSteps: [': -2'],
    ),
    InequalityProblem(
      variable: 'a',
      startCoeff: -4,
      startOperator: '<',
      startConst: 20,
      targetConst: -5,
      targetOperator: '>', // -4a < 20 -> a > -5
      recommendedSteps: [': -4'],
    ),
  ];

  int currentProblemIndex = 0;
  late double currentCoeff;
  late String currentOperator;
  late double currentConst;

  String actionOp = '/';
  String inputValue = '-5';
  bool _isFlipped = false;
  String feedbackMessage = "Isoleer de variabele. Pas op bij vermenigvuldigen/delen met een negatief getal!";
  bool hasWonCurrent = false;

  @override
  void initState() {
    super.initState();
    _loadProblem(0);
  }

  void _loadProblem(int index) {
    final p = problems[index];
    setState(() {
      currentProblemIndex = index;
      currentCoeff = p.startCoeff;
      currentOperator = p.startOperator;
      currentConst = p.startConst;
      _isFlipped = false;
      hasWonCurrent = false;
      inputValue = p.recommendedSteps.isNotEmpty ? p.recommendedSteps[0].replaceAll(': ', '').replaceAll('/ ', '') : '-5';
      feedbackMessage = "Doel: Isoleer '${p.variable}'. Let goed op het omklappen van het teken!";
    });
  }

  void _applyOperation(String op, String valStr) {
    if (hasWonCurrent) return;

    final double? val = double.tryParse(valStr.trim());
    if (val == null || (val == 0 && (op == '/' || op == ':'))) {
      SoundEngine().playErrorSound();
      setState(() {
        feedbackMessage = "Foutieve invoer of delen door 0!";
      });
      return;
    }

    setState(() {
      if (op == '+') {
        currentConst += val;
      } else if (op == '-') {
        currentConst -= val;
      } else if (op == '*') {
        currentCoeff *= val;
        currentConst *= val;
        if (val < 0) _flipOperator();
      } else if (op == '/' || op == ':') {
        currentCoeff /= val;
        currentConst /= val;
        if (val < 0) _flipOperator();
      }
    });

    SoundEngine().playClickSound();
    _checkWinCondition();
  }

  void _flipOperator() {
    SoundEngine().playFlipSound();
    _isFlipped = !_isFlipped;
    if (currentOperator == '>') {
      currentOperator = '<';
    } else if (currentOperator == '<') {
      currentOperator = '>';
    } else if (currentOperator == r'\ge' || currentOperator == '>=') {
      currentOperator = r'\le';
    } else if (currentOperator == r'\le' || currentOperator == '<=') {
      currentOperator = r'\ge';
    }

    feedbackMessage = "🔄 Dimensie Klap! Gedeeld/vermenigvuldigd met een negatief getal: teken klapt om!";
  }

  void _checkWinCondition() {
    final p = problems[currentProblemIndex];
    final bool isCorrectCoeff = (currentCoeff - 1).abs() < 0.01;
    final bool isCorrectConst = (currentConst - p.targetConst).abs() < 0.01;
    final bool isCorrectOp = currentOperator == p.targetOperator;

    if (isCorrectCoeff && isCorrectConst && isCorrectOp) {
      hasWonCurrent = true;
      setState(() {
        feedbackMessage = "🎉 Uitstekend! ${p.variable} $currentOperator ${p.targetConst.round()}";
      });
      SoundEngine().playVictoryFanfare();

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (currentProblemIndex < problems.length - 1) {
          _loadProblem(currentProblemIndex + 1);
        } else {
          LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, '');
        }
      });
    }
  }

  String _formatTexLeft(double val, String varName) {
    final double r = (val * 100).round() / 100;
    if ((r - 1).abs() < 0.001) return varName;
    if ((r + 1).abs() < 0.001) return "-$varName";
    return "${r == r.roundToDouble() ? r.round() : r}$varName";
  }

  String _formatTexRight(double val) {
    final double r = (val * 100).round() / 100;
    return "${r == r.roundToDouble() ? r.round() : r}";
  }

  @override
  Widget build(BuildContext context) {
    final p = problems[currentProblemIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              // Header
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
                        Text(
                          "Opgave ${currentProblemIndex + 1} van ${problems.length}: Ongelijkheid",
                          style: const TextStyle(
                            color: AxiomTheme.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _loadProblem(currentProblemIndex),
                          icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                          label: const Text("Herstart som", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Regel: Bij delen of vermenigvuldigen met een negatief getal klapt het ongelijkheidsteken om.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ).animate(key: ValueKey(feedbackMessage)).fadeIn(),

              const SizedBox(height: 32),

              // 3D Card Flip KaTeX Box
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
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
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
                        transform: Matrix4.identity()..rotateY(val >= pi / 2 ? pi : 0),
                        child: Math.tex(
                          "${_formatTexLeft(currentCoeff, p.variable)} $currentOperator ${_formatTexRight(currentConst)}",
                          textStyle: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Getallenlijn visualisatie
              _buildNumberLine(p),

              const SizedBox(height: 28),

              // Bediening
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Kies een bewerking om toe te passen:",
                      style: TextStyle(color: AxiomTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: actionOp,
                              dropdownColor: const Color(0xFF161B22),
                              items: const [
                                DropdownMenuItem(value: '+', child: Text("+ (Optellen)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: '-', child: Text("- (Aftrekken)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: '*', child: Text("· (Vermenigvuldigen)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: '/', child: Text(": (Delen)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => actionOp = v);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            onChanged: (v) => inputValue = v,
                            onSubmitted: (v) => _applyOperation(actionOp, v),
                            controller: TextEditingController(text: inputValue)
                              ..selection = TextSelection.collapsed(offset: inputValue.length),
                            decoration: InputDecoration(
                              hintText: "bijv. -5",
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyOperation(actionOp, inputValue),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AxiomTheme.primaryCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("TOEPASSEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildNumberLine(InequalityProblem p) {
    final bool isLessThan = currentOperator == '<' || currentOperator == r'\le';
    final bool isStrict = currentOperator == '<' || currentOperator == '>';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Getallenlijn weergave:", style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(
                isStrict ? "Open bolletje ⚪ (strikt)" : "Dicht bolletje ⚫ (inclusief)",
                style: const TextStyle(color: AxiomTheme.accentGold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: CustomPaint(
              size: const Size(double.infinity, 48),
              painter: _NumberLinePainter(
                targetVal: p.targetConst,
                isLessThan: isLessThan,
                isStrict: isStrict,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  final double targetVal;
  final bool isLessThan;
  final bool isStrict;

  _NumberLinePainter({
    required this.targetVal,
    required this.isLessThan,
    required this.isStrict,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height / 2;
    final linePaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2;

    // Aslijn
    canvas.drawLine(Offset(20, lineY), Offset(size.width - 20, lineY), linePaint);

    // Pijlen aan weerszijden van as
    canvas.drawLine(Offset(25, lineY - 5), Offset(20, lineY), linePaint);
    canvas.drawLine(Offset(25, lineY + 5), Offset(20, lineY), linePaint);
    canvas.drawLine(Offset(size.width - 25, lineY - 5), Offset(size.width - 20, lineY), linePaint);
    canvas.drawLine(Offset(size.width - 25, lineY + 5), Offset(size.width - 20, lineY), linePaint);

    // Middenpunt
    final midX = size.width / 2;

    // Oplossingsgebied (gekleurde dikke lijn met pijl)
    final solPaint = Paint()
      ..color = AxiomTheme.primaryCyan
      ..strokeWidth = 5;

    if (isLessThan) {
      canvas.drawLine(Offset(20, lineY), Offset(midX, lineY), solPaint);
      canvas.drawLine(Offset(30, lineY - 7), Offset(20, lineY), solPaint);
      canvas.drawLine(Offset(30, lineY + 7), Offset(20, lineY), solPaint);
    } else {
      canvas.drawLine(Offset(midX, lineY), Offset(size.width - 20, lineY), solPaint);
      canvas.drawLine(Offset(size.width - 30, lineY - 7), Offset(size.width - 20, lineY), solPaint);
      canvas.drawLine(Offset(size.width - 30, lineY + 7), Offset(size.width - 20, lineY), solPaint);
    }

    // Bolletje
    final circlePaint = Paint()
      ..color = isStrict ? const Color(0xFF0F141C) : AxiomTheme.accentGold
      ..style = PaintingStyle.fill;
    final circleBorder = Paint()
      ..color = AxiomTheme.accentGold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(midX, lineY), 7, circlePaint);
    canvas.drawCircle(Offset(midX, lineY), 7, circleBorder);

    // Label onder bolletje
    final textSpan = TextSpan(
      text: "${targetVal.round()}",
      style: const TextStyle(color: AxiomTheme.accentGold, fontSize: 13, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(midX - textPainter.width / 2, lineY + 12));
  }

  @override
  bool shouldRepaint(covariant _NumberLinePainter oldDelegate) {
    return oldDelegate.targetVal != targetVal ||
        oldDelegate.isLessThan != isLessThan ||
        oldDelegate.isStrict != isStrict;
  }
}
