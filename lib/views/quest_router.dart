import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import 'quest_view.dart';

class QuestRouter extends StatelessWidget {
  final Quest quest;

  const QuestRouter({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return QuestView(quest: quest);
  }
}
