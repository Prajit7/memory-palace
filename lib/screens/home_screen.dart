import 'package:flutter/material.dart';

import '../data.dart';
import '../game.dart';
import '../progress.dart';
import '../theme.dart';
import 'study_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void startLevel(BuildContext context, int number) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudyScreen(level: Level.generate(number))));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final themeIcon = switch (progress.themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Memory Palace', style: text.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Remember more than you think you can.',
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ]),
                ),
                IconButton(
                  tooltip: 'Theme: ${progress.themeMode.name}',
                  icon: Icon(themeIcon),
                  onPressed: progress.cycleTheme,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _NextUpCard(level: progress.unlocked),
            const SizedBox(height: 28),
            Row(children: [
              Text('Levels', style: text.titleLarge),
              const Spacer(),
              const Icon(Icons.star_rounded, color: starGold, size: 20),
              const SizedBox(width: 4),
              Text('${progress.totalStars} / ${Level.maxLevel * 3}',
                  style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ]),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (var n = 1; n <= Level.maxLevel; n++)
                  _LevelTile(number: n, stars: progress.starsFor(n), locked: n > progress.unlocked),
              ],
            ),
            const SizedBox(height: 28),
            const _HowItWorks(),
          ],
        ),
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  const _NextUpCard({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, Color.lerp(scheme.primary, scheme.tertiary, .55)!],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NEXT UP',
                  style: text.labelMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: .8), letterSpacing: 1.4, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Level $level', style: text.headlineLarge?.copyWith(color: scheme.onPrimary)),
              const SizedBox(height: 4),
              Text('${Level.itemCount(level)} things hidden in ${rooms.length} rooms',
                  style: text.bodyLarge?.copyWith(color: scheme.onPrimary.withValues(alpha: .9))),
            ]),
          ),
          const Text('🏛️', style: TextStyle(fontSize: 56)),
        ]),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: scheme.onPrimary, foregroundColor: scheme.primary),
          onPressed: () => HomeScreen.startLevel(context, level),
          icon: const Icon(Icons.directions_walk_rounded),
          label: const Text('Start the walk'),
        ),
      ]),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.number, required this.stars, required this.locked});

  final int number;
  final int stars;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: locked ? scheme.surfaceContainerLow : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: locked ? null : () => HomeScreen.startLevel(context, number),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (locked)
            Icon(Icons.lock_rounded, color: scheme.outline, size: 22)
          else
            Text('$number', style: text.titleLarge),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < 3; i++)
              Icon(
                Icons.star_rounded,
                size: 14,
                color: i < stars ? starGold : scheme.outlineVariant,
              ),
          ]),
        ]),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const steps = [
    ('Walk', 'Go room by room. At every stop something strange is happening.'),
    ('Picture it', 'Imagine each scene in detail: the noise, the size, the mess. Weird pictures stick.'),
    ('Recall', 'Walk the house again in your head and answer questions about what you saw.'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('How it works', style: text.titleLarge),
        const SizedBox(height: 14),
        for (var i = 0; i < steps.length; i++) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.primaryContainer,
              child: Text('${i + 1}',
                  style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(steps[i].$1, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(steps[i].$2, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
        ],
        Text(
          'This is the method of loci. Memory champions use it to remember a whole shuffled deck of cards.',
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic),
        ),
      ]),
    );
  }
}
