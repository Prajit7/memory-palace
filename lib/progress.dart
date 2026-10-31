import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';

/// Unlocked level, best stars per level and theme choice, saved on device.
class Progress extends ChangeNotifier {
  Progress._(this._prefs);

  final SharedPreferences _prefs;
  int unlocked = 1;
  final Map<int, int> _stars = {};
  ThemeMode themeMode = ThemeMode.system;

  static Future<Progress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final p = Progress._(prefs);
    p.unlocked = (prefs.getInt('unlocked') ?? 1).clamp(1, Level.maxLevel);
    for (final entry in prefs.getStringList('stars') ?? const <String>[]) {
      final parts = entry.split(':');
      final level = int.tryParse(parts.first);
      final stars = parts.length == 2 ? int.tryParse(parts[1]) : null;
      if (level != null && stars != null) p._stars[level] = stars;
    }
    p.themeMode = ThemeMode.values[(prefs.getInt('theme') ?? 0).clamp(0, 2)];
    return p;
  }

  int starsFor(int level) => _stars[level] ?? 0;
  int get totalStars => _stars.values.fold(0, (a, b) => a + b);

  void recordResult(int level, int stars) {
    if (stars > starsFor(level)) _stars[level] = stars;
    if (stars > 0 && level == unlocked && level < Level.maxLevel) unlocked++;
    _save();
    notifyListeners();
  }

  /// System → light → dark → system.
  void cycleTheme() {
    themeMode = ThemeMode.values[(themeMode.index + 1) % 3];
    _save();
    notifyListeners();
  }

  void _save() {
    _prefs.setInt('unlocked', unlocked);
    _prefs.setStringList('stars', [for (final e in _stars.entries) '${e.key}:${e.value}']);
    _prefs.setInt('theme', themeMode.index);
  }
}

class ProgressScope extends InheritedNotifier<Progress> {
  const ProgressScope({super.key, required Progress progress, required super.child}) : super(notifier: progress);

  /// Use in build methods; rebuilds when progress changes.
  static Progress of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProgressScope>()!.notifier!;

  /// Use in callbacks.
  static Progress read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProgressScope>()!.notifier!;
}
