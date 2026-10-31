import 'package:flutter/material.dart';

import '../game.dart';
import '../theme.dart';
import 'study_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.level,
    required this.correct,
    required this.total,
    required this.stars,
    required this.missed,
    required this.orderCorrect,
    required this.studyTime,
  });

  final Level level;
  final int correct;
  final int total;
  final int stars;
  final Set<int> missed;
  final bool? orderCorrect;
  final Duration studyTime;

  void _play(BuildContext context, int number) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => StudyScreen(level: Level.generate(number))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final headline = switch (stars) {
      3 => 'Perfect palace!',
      2 => 'Great memory',
      1 => 'Level passed',
      _ => 'Almost there',
    };
    final mins = studyTime.inMinutes, secs = studyTime.inSeconds % 60;
    final studied = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';
    final canAdvance = stars > 0 && level.number < Level.maxLevel;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back to home',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: ListView(children: [
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < 3; i++)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + i * 180),
                      curve: Curves.elasticOut,
                      builder: (context, v, child) => Transform.scale(scale: v, child: child),
                      child: Icon(
                        Icons.star_rounded,
                        size: i == 1 ? 72 : 56,
                        color: i < stars ? starGold : scheme.outlineVariant,
                      ),
                    ),
                ]),
                const SizedBox(height: 12),
                Text(headline, textAlign: TextAlign.center, style: text.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  '$correct of $total right · studied for $studied',
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
                if (stars == 0) ...[
                  const SizedBox(height: 4),
                  Text('Get 60% right to unlock the next level.',
                      textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 28),
                Text('Your walk', style: text.titleLarge),
                const SizedBox(height: 10),
                for (final p in level.placements)
                  _WalkRow(placement: p, missed: missed.contains(p.order)),
                if (orderCorrect != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(orderCorrect! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: orderCorrect! ? scheme.good : scheme.bad, size: 20),
                    const SizedBox(width: 8),
                    Text(orderCorrect! ? 'Order question: right' : 'Order question: wrong',
                        style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            if (canAdvance) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _play(context, level.number + 1),
                  child: Text('Level ${level.number + 1} · ${Level.itemCount(level.number + 1)} things'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: canAdvance
                  ? OutlinedButton(onPressed: () => _play(context, level.number), child: const Text('New walk, same level'))
                  : FilledButton(onPressed: () => _play(context, level.number), child: const Text('Try a new walk')),
            ),
          ]),
        ),
      ),
    );
  }
}

class _WalkRow extends StatelessWidget {
  const _WalkRow({required this.placement, required this.missed});

  final Placement placement;
  final bool missed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final p = placement;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: missed ? scheme.bad.withValues(alpha: .1) : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Text(p.room.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.room.name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text(capitalize(p.spot), style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        ),
        Text(p.item.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 10),
        Icon(
          missed ? Icons.close_rounded : Icons.check_rounded,
          color: missed ? scheme.bad : scheme.good,
          size: 20,
          semanticLabel: missed ? 'Missed' : 'Remembered',
        ),
      ]),
    );
  }
}
