import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile extends ChangeNotifier {
  int xp = 0;
  int level = 1;
  int currentStreak = 0;
  List<String> unlockedNodes = ['q1'];
  Map<String, int> questStars = {}; // Quest ID to Stars (1-3)

  static const _xpKey = 'axiom_xp';
  static const _levelKey = 'axiom_level';
  static const _streakKey = 'axiom_streak';
  static const _unlockedKey = 'axiom_unlocked';
  static const _starsKeyPrefix = 'axiom_stars_';

  PlayerProfile() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    xp = prefs.getInt(_xpKey) ?? 0;
    level = prefs.getInt(_levelKey) ?? 1;
    currentStreak = prefs.getInt(_streakKey) ?? 0;
    unlockedNodes = prefs.getStringList(_unlockedKey) ?? ['q1'];
    
    // Load stars (we could save all keys that start with prefix)
    for (String key in prefs.getKeys()) {
      if (key.startsWith(_starsKeyPrefix)) {
        String questId = key.substring(_starsKeyPrefix.length);
        questStars[questId] = prefs.getInt(key) ?? 0;
      }
    }
    notifyListeners();
  }

  Future<void> addXP(int amount) async {
    xp += amount;
    int nextLevelXP = level * 500;
    if (xp >= nextLevelXP) {
      level++;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, xp);
    await prefs.setInt(_levelKey, level);
    notifyListeners();
  }

  Future<void> incrementStreak() async {
    currentStreak++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, currentStreak);
    notifyListeners();
  }

  Future<void> resetStreak() async {
    currentStreak = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, currentStreak);
    notifyListeners();
  }

  Future<void> completeQuest(String questId, int stars) async {
    if ((questStars[questId] ?? 0) < stars) {
      questStars[questId] = stars;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_starsKeyPrefix$questId', stars);
    }
    notifyListeners();
  }

  Future<void> unlockNode(String questId) async {
    if (!unlockedNodes.contains(questId)) {
      unlockedNodes.add(questId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_unlockedKey, unlockedNodes);
      notifyListeners();
    }
  }
}
