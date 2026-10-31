// Design preview: opens one screen directly for screenshots.
// Build: flutter build web -t lib/dev/preview_main.dart -o build/preview
// Open:  index.html?screen=home|study|recall|result&dark=1
import 'dart:math';

import 'package:flutter/material.dart';

import '../game.dart';
import '../progress.dart';
import '../screens/home_screen.dart';
import '../screens/recall_screen.dart';
import '../screens/result_screen.dart';
import '../screens/study_screen.dart';
import '../theme.dart';
import '../widgets/phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  final q = Uri.base.queryParameters;
  final level = Level.generate(3, random: Random(7));
  final Widget screen = switch (q['screen']) {
    'study' => StudyScreen(level: level),
    'recall' => RecallScreen(level: level, studyTime: const Duration(seconds: 74)),
    'result' => ResultScreen(
        level: level,
        correct: 6,
        total: 8,
        stars: 1,
        missed: {1, 4},
        orderCorrect: true,
        studyTime: const Duration(seconds: 74),
      ),
    _ => const HomeScreen(),
  };
  runApp(ProgressScope(
    progress: progress,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: q['dark'] == '1' ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => PhoneFrame(child: child!),
      home: screen,
    ),
  ));
}
