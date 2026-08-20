import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class BalanceEquation {
  final String variable;
  final double startLeftVar;
  final double startLeftConst;
  final double startRightVar;
  final double startRightConst;
  final double targetAnswer; // geheel getal als oplossing

  BalanceEquation({
    required this.variable,
    required this.startLeftVar,
    required this.startLeftConst,
    required this.startRightVar,
    required this.startRightConst,
    required this.targetAnswer,
  });
}

class BalanceGame extends StatefulWidget {
  final Quest quest;
  const BalanceGame({super.key, required this.quest});

  @override
  State<BalanceGame> createState() => _BalanceGameState();
}

class _BalanceGameState extends State<BalanceGame> {
  final List<BalanceEquation> equations = [
    BalanceEquation(
      variable: 'q',
      startLeftVar: 5,
      startLeftConst: -22,
      startRightVar: -2,
      startRightConst: 48,
      targetAnswer: 10, // 5q - 22 = -2q + 48 -> 7q = 70 -> q = 10
    ),
    BalanceEquation(
      variable: 'x',
      startLeftVar: 4,
      startLeftConst: 15,
      startRightVar: 2,
      startRightConst: 27,
      targetAnswer: 6, // 4x + 15 = 2x + 27 -> 2x = 12 -> x = 6
    ),
    BalanceEquation(
      variable: 'y',
      startLeftVar: 3,
      startLeftConst: -8,
      startRightVar: -1,
      startRightConst: 16,
      targetAnswer: 6, // 3y - 8 = -y + 16 -> 4y = 24 -> y = 6
    ),
  ];

  int currentEquationIndex = 0;
  late double leftVar;
  late double leftConst;
  late double rightVar;
  late double rightConst;

  String operation = '+';
  String inputValue = '';
  String statusMessage = "Isoleer de variabele links van het =-teken.";
  final List<String> stepHistory = [];
  bool hasWonCurrent = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEquation(0);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadEquation(int index) {
    final eq = equations[index];
    setState(() {
      currentEquationIndex = index;
      leftVar = eq.startLeftVar;
      leftConst = eq.startLeftConst;
      rightVar = eq.startRightVar;
      rightConst = eq.startRightConst;
      hasWonCurrent = false;
      stepHistory.clear();
      statusMessage = "Isoleer '${eq.variable}' aan de linkerkant.";
      inputValue = '';
      _textController.clear();
    });
  }

  void _applyOperation(String op, String valStr) {
    if (hasWonCurrent) return;

    final eq = equations[currentEquationIndex];
    double varMod = 0;
    double constMod = 0;

    valStr = valStr.trim().replaceAll(' ', '');
    if (valStr.isEmpty) return;

    if (valStr.endsWith(eq.variable)) {
      final prefix = valStr.substring(0, valStr.length - 1);
      if (prefix.isEmpty || prefix == '+') {
        varMod = 1;
      } else if (prefix == '-') {
        varMod = -1;
      } else {
        varMod = double.tryParse(prefix) ?? 0;
      }
    } else {
      constMod = double.tryParse(valStr) ?? 0;
    }

    final String stepDesc = "$op $valStr";

    setState(() {
      if (op == '+') {
        leftVar += varMod;
        rightVar += varMod;
        leftConst += constMod;
        rightConst += constMod;
      } else if (op == '-') {
        leftVar -= varMod;
        rightVar -= varMod;
        leftConst -= constMod;
        rightConst -= constMod;
      } else if (op == '*') {
        if (constMod != 0) {
          leftVar *= constMod;
          rightVar *= constMod;
          leftConst *= constMod;
          rightConst *= constMod;
        }
      } else if (op == '/' || op == ':') {
        if (constMod != 0) {
          leftVar /= constMod;
          rightVar /= constMod;
          leftConst /= constMod;
          rightConst /= constMod;
        }
      }
      stepHistory.add("Beide zijden: $stepDesc");
      _textController.clear();
      inputValue = '';
    });

    SoundEngine().playClickSound();
    _checkWinCondition();
  }

  void _checkWinCondition() {
    final eq = equations[currentEquationIndex];
    final double diffLeftVar = (leftVar - 1).abs();
    final double diffLeftConst = leftConst.abs();
    final double diffRightVar = rightVar.abs();
    final double diffAnswer = (rightConst - eq.targetAnswer).abs();

    if (diffLeftVar < 0.01 && diffLeftConst < 0.01 && diffRightVar < 0.01 && diffAnswer < 0.01) {
      hasWonCurrent = true;
      setState(() {
        statusMessage = "Opgelost: ${eq.variable} = ${eq.targetAnswer.round()}";
      });
      SoundEngine().playVictoryFanfare();

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (currentEquationIndex < equations.length - 1) {
          _loadEquation(currentEquationIndex + 1);
        } else {
          LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q3');
        }
      });
    }
  }

  String _formatTex(double vCoeff, double c, String variableName) {
    String res = "";
    if (vCoeff.abs() > 0.001) {
      final double roundV = (vCoeff * 100).round() / 100;
      if ((roundV - 1).abs() < 0.001) {
        res += variableName;
      } else if ((roundV + 1).abs() < 0.001) {
        res += "-$variableName";
      } else {
        res += "${roundV == roundV.roundToDouble() ? roundV.round() : roundV}$variableName";
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

  @override
  Widget build(BuildContext context) {
    final eq = equations[currentEquationIndex];
    final double trueVal = eq.targetAnswer;
    final double leftWeight = leftVar * trueVal + leftConst;
    final double rightWeight = rightVar * trueVal + rightConst;
    final double tilt = ((leftWeight - rightWeight) / 80.0).clamp(-0.25, 0.25);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              // Header balk
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
                          "Opgave ${currentEquationIndex + 1} van ${equations.length}: Balansmethode",
                          style: const TextStyle(
                            color: AxiomTheme.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _loadEquation(currentEquationIndex),
                          icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                          label: const Text("Herstart som", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Balans: ", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Math.tex(
                          "${_formatTex(leftVar, leftConst, eq.variable)} = ${_formatTex(rightVar, rightConst, eq.variable)}",
                          textStyle: const TextStyle(
                            fontSize: 22,
                            color: AxiomTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 32),

              // Weegschaal animatie
              SizedBox(
                height: 230,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 135,
                      color: Colors.grey.shade600,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 140),
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AxiomTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Transform.rotate(
                      angle: tilt,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 145),
                        width: 440,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AxiomTheme.accentGold,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPan(_formatTex(leftVar, leftConst, eq.variable), Colors.cyan.shade900),
                            _buildPan(_formatTex(rightVar, rightConst, eq.variable), Colors.purple.shade900),
                          ],
                        ),
                      ),
                    ).animate(target: tilt).rotate(duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bedieningspaneel met directe operator-knoppen (geen dropdown)
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
                      "Kies een bewerking om op beide zijden toe te passen:",
                      style: TextStyle(color: AxiomTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Directe operator-knoppen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOpButton('+', '+ (Plus)'),
                        const SizedBox(width: 8),
                        _buildOpButton('-', '- (Min)'),
                        const SizedBox(width: 8),
                        _buildOpButton('*', '· (Keer)'),
                        const SizedBox(width: 8),
                        _buildOpButton('/', ': (Delen)'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 170,
                          child: TextField(
                            controller: _textController,
                            onChanged: (v) => inputValue = v,
                            onSubmitted: (v) => _applyOperation(operation, v),
                            decoration: InputDecoration(
                              hintText: "bijv. 2${eq.variable} of 22",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: Colors.black45,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyOperation(operation, inputValue),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AxiomTheme.primaryCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("TOEPASSEN OP BEIDE KANTEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (stepHistory.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Uitgevoerde stappen:",
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepHistory.join("  ➜  "),
                        style: const TextStyle(color: AxiomTheme.accentGold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpButton(String opCode, String label) {
    final isSelected = operation == opCode;
    return InkWell(
      onTap: () {
        setState(() => operation = opCode);
        SoundEngine().playClickSound();
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AxiomTheme.primaryCyan : const Color(0xFF0F141C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AxiomTheme.primaryCyan : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPan(String tex, Color color) {
    return Transform.translate(
      offset: const Offset(0, 44),
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
