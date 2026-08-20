import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../games/level1_fusion.dart';
import '../games/level2_forge.dart';
import '../games/level3_balance.dart';
import '../games/level4_inequality.dart';
import '../core/theme.dart';

class QuestRouter extends StatelessWidget {
  final Quest quest;

  const QuestRouter({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    Widget gameWidget;
    switch (quest.type) {
      case QuestType.fusion:
        gameWidget = FusionGame(quest: quest);
        break;
      case QuestType.forge:
        gameWidget = ForgeGame(quest: quest);
        break;
      case QuestType.balance:
        gameWidget = BalanceGame(quest: quest);
        break;
      case QuestType.inequality:
        gameWidget = InequalityGame(quest: quest);
        break;
    }

    return Scaffold(
      backgroundColor: AxiomTheme.background,
      appBar: AppBar(
        title: Text(
          quest.title,
          style: const TextStyle(
            color: AxiomTheme.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF161B22),
        elevation: 2,
        leading: IconButton(
          tooltip: 'Terug naar overzicht',
          icon: const Icon(Icons.arrow_back, color: AxiomTheme.primaryCyan),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: gameWidget,
    );
  }
}
