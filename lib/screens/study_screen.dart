import 'package:flutter/material.dart';

import '../data.dart';
import '../game.dart';
import '../widgets/floor_plan.dart';
import '../widgets/top_bar.dart';
import 'recall_screen.dart';

/// The walk: one stop at a time through the house.
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.level});

  final Level level;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _watch = Stopwatch()..start();
  int _index = 0;
  bool _forward = true;

  List<Placement> get _stops => widget.level.placements;

  void _next() {
    if (_index < _stops.length - 1) {
      setState(() {
        _forward = true;
        _index++;
      });
      return;
    }
    _watch.stop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => RecallScreen(level: widget.level, studyTime: _watch.elapsed),
    ));
  }

  void _back() => setState(() {
        _forward = false;
        _index--;
      });

  @override
  Widget build(BuildContext context) {
    final stop = _stops[_index];
    final roomIndex = rooms.indexOf(stop.room);
    final isLast = _index == _stops.length - 1;
    final visited = {for (final p in _stops.take(_index + 1)) rooms.indexOf(p.room)};

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
          child: Column(children: [
            TopBar(title: 'Level ${widget.level.number} · The walk', step: _index + 1, total: _stops.length),
            const SizedBox(height: 16),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Center(child: FloorPlan(current: roomIndex, visited: visited, routeTo: roomIndex)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) {
                    final incoming = child.key == ValueKey(_index);
                    final dx = (incoming == _forward) ? .15 : -.15;
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: _StopCard(key: ValueKey(_index), stop: stop, showTip: _index == 0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(children: [
                if (_index > 0) ...[
                  OutlinedButton(
                    onPressed: _back,
                    child: const Icon(Icons.arrow_back_rounded, semanticLabel: 'Previous stop'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(isLast ? 'I’ve got it, quiz me' : 'Next stop'),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({super.key, required this.stop, required this.showTip});

  final Placement stop;
  final bool showTip;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(builder: (context, box) {
        final emojiSize = (box.maxHeight * .26).clamp(40.0, 80.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${stop.room.emoji}  ${stop.room.name.toUpperCase()}',
                  style: text.labelMedium?.copyWith(
                      letterSpacing: 1.2, fontWeight: FontWeight.w800, color: scheme.primary),
                ),
                const SizedBox(height: 8),
                Text(stop.item.emoji, style: TextStyle(fontSize: emojiSize)),
                const SizedBox(height: 8),
                Text(
                  stop.story,
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(height: 1.3),
                ),
                if (showTip) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Close your eyes for a second and really see it. Silly is good.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
