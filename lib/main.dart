import 'package:flutter/material.dart';

import 'progress.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'widgets/phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await Progress.load();
  runApp(MemoryPalaceApp(progress: progress));
}

class MemoryPalaceApp extends StatelessWidget {
  const MemoryPalaceApp({super.key, required this.progress});

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: progress,
      child: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => MaterialApp(
          title: 'Memory Palace',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: progress.themeMode,
          builder: (context, child) => PhoneFrame(child: child!),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
