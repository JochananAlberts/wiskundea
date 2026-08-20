import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/sound_engine.dart';

class MathInputToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String primaryVariable;

  const MathInputToolbar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.primaryVariable = 'x',
  });

  void _insertSymbol(String symbol) {
    SoundEngine().playClickSound();
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, symbol);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + symbol.length),
      );
    } else {
      final newText = text + symbol;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  void _backspace() {
    SoundEngine().playClickSound();
    final text = controller.text;
    final selection = controller.selection;

    if (text.isEmpty) return;

    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.start, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    } else if (selection.start != selection.end) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    } else {
      final newText = text.substring(0, text.length - 1);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  void _clear() {
    SoundEngine().playClickSound();
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> symbols = [
      primaryVariable,
      if (primaryVariable != 'x') 'x',
      if (primaryVariable != 'y') 'y',
      '²',
      '³',
      '^',
      '+',
      '-',
      '·',
      '/',
      '(',
      ')',
      '=',
      '<',
      '>',
      '≤',
      '≥',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...symbols.map((s) => _buildKey(s, () => _insertSymbol(s))),
                const SizedBox(width: 6),
                _buildActionKey(Icons.backspace_outlined, _backspace, tooltip: 'Wissen'),
                const SizedBox(width: 4),
                _buildActionKey(Icons.clear_all, _clear, tooltip: 'Leegmaken'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AxiomTheme.primaryPurple.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AxiomTheme.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onTap, {required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: AxiomTheme.primaryCyan, size: 18),
        ),
      ),
    );
  }
}
