import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'models/player_profile.dart';
import 'views/dashboard_view.dart';
// Note: using go_router or simple Hash routing isn't strictly necessary for a single page app 
// unless deeply linking. We'll use a simple approach for the prototype.
// GitHub Pages will just load index.html.

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProfile()),
      ],
      child: const AxiomApp(),
    ),
  );
}

class AxiomApp extends StatelessWidget {
  const AxiomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Axiom RPG',
      debugShowCheckedModeBanner: false,
      theme: AxiomTheme.themeData,
      home: const DashboardView(),
    );
  }
}
