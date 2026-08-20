import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/curriculum.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';
import '../views/level_complete_dialog.dart';

class Term {
  int coeff;
  String variable;
  int exponent;
  
  Term(this.coeff, this.variable, this.exponent);
  
  String get display {
    if (coeff == 0) return "0";
    String c = coeff == 1 && variable.isNotEmpty ? "" : (coeff == -1 && variable.isNotEmpty ? "-" : coeff.toString());
    String v = variable;
    String e = exponent > 1 ? "^$exponent" : "";
    if (variable.isEmpty) return coeff.toString();
    return "$c$v$e";
  }
}

class FusionGame extends StatefulWidget {
  final Quest quest;
  const FusionGame({Key? key, required this.quest}) : super(key: key);

  @override
  _FusionGameState createState() => _FusionGameState();
}

class _FusionGameState extends State<FusionGame> {
  List<Term?> grid = [];
  bool isMultiplication = false;
  int score = 0;
  int targetScore = 3; 
  String feedbackMessage = "Combine terms to reach the target!";

  @override
  void initState() {
    super.initState();
    _initGrid();
  }

  void _initGrid() {
    grid = [
      Term(3, 'x', 1), Term(2, 'x', 1), Term(4, 'x', 2),
      Term(5, 'x', 2), Term(2, 'a', 3), Term(3, 'a', 3),
      null, null, null
    ];
  }

  bool _canFuse(Term a, Term b) {
    if (isMultiplication) {
      return a.variable == b.variable; // Can multiply if same variable base
    } else {
      return a.variable == b.variable && a.exponent == b.exponent; // Can add if like terms
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
        // Just move
        grid[toIndex] = fromTerm;
        grid[fromIndex] = null;
        SoundEngine().playClickSound();
      } else {
        // Attempt fusion
        if (_canFuse(fromTerm, toTerm)) {
          grid[toIndex] = _fuse(fromTerm, toTerm);
          grid[fromIndex] = null;
          SoundEngine().playFusionSound();
          score++;
          feedbackMessage = "Great fusion!";
          if (score >= targetScore) {
            Future.delayed(const Duration(milliseconds: 500), () {
              LevelCompleteDialog.show(context, widget.quest, 3, widget.quest.baseXP, 'q2');
            });
          }
        } else {
          SoundEngine().playErrorSound();
          feedbackMessage = "Cannot fuse unlike terms!";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mode:", style: AxiomTheme.themeData.textTheme.bodyLarge),
              SwitchListTile(
                title: Text(isMultiplication ? "Multiply (x * x)" : "Add (x + x)", style: TextStyle(color: AxiomTheme.primaryCyan)),
                value: isMultiplication,
                onChanged: (val) {
                  setState(() {
                    isMultiplication = val;
                    feedbackMessage = isMultiplication ? "Multiply mode activated" : "Add mode activated";
                  });
                  SoundEngine().playClickSound();
                },
              ),
            ],
          ),
        ),
        Text(feedbackMessage, style: TextStyle(color: AxiomTheme.accentGold, fontSize: 18)).animate(key: ValueKey(feedbackMessage)).fadeIn().shake(),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 350,
              height: 350,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (ctx, index) {
                  return DragTarget<int>(
                    onAccept: (fromIndex) => _handleDrop(fromIndex, index),
                    builder: (ctx, candidateData, rejectedData) {
                      final term = grid[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AxiomTheme.themeData.cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: candidateData.isNotEmpty ? AxiomTheme.primaryCyan : AxiomTheme.primaryPurple,
                            width: 2
                          )
                        ),
                        child: term == null ? null : Draggable<int>(
                          data: index,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildTile(term.display, isDragging: true),
                          ),
                          childWhenDragging: Opacity(opacity: 0.3, child: _buildTile(term.display)),
                          child: _buildTile(term.display),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(String text, {bool isDragging = false}) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: isDragging ? AxiomTheme.primaryPurple.withOpacity(0.8) : AxiomTheme.primaryPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AxiomTheme.textWhite)),
    );
  }
}
