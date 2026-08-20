import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../games/level1_fusion.dart';
import '../games/level2_forge.dart';
import '../games/level3_balance.dart';
import '../games/level4_inequality.dart';
import '../core/theme.dart';

class QuestRouter extends StatelessWidget {
  final Quest quest;
  
  const QuestRouter({Key? key, required this.quest}) : super(key: key);

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
      default:
        gameWidget = Center(child: Text("Coming soon!", style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: AxiomTheme.background,
      appBar: AppBar(
        title: Text(quest.title, style: AxiomTheme.themeData.textTheme.bodyLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: gameWidget,
    );
  }
}
