import 'package:flutter/material.dart';

import '../data.dart';
import '../game.dart';
import '../progress.dart';
import '../theme.dart';
import '../widgets/floor_plan.dart';
import '../widgets/top_bar.dart';
import 'result_screen.dart';

/// The quiz: what was where, where was what, and in which order.
class RecallScreen extends StatefulWidget {
  const RecallScreen({super.key, required this.level, required this.studyTime});

  final Level level;
  final Duration studyTime;

  @override
  State<RecallScreen> createState() => _RecallScreenState();
}

class _RecallScreenState extends State<RecallScreen> {
  late final List<Question> _questions = widget.level.buildQuiz();
  final Set<int> _missed = {}; // placement orders answered wrong
  int _qi = 0;
  int _correct = 0;
  bool? _orderCorrect;

  // State of the current question.
  bool _answered = false;
  bool _wasRight = false;
  Item? _pickedItem;
  int? _pickedRoom;
  final List<Placement> _picked = [];

  Question get _q => _questions[_qi];

  void _resolve(bool right, {Placement? target}) {
    setState(() {
      _answered = true;
      _wasRight = right;
      if (right) {
        _correct++;
      } else if (target != null) {
        _missed.add(target.order);
      }
    });
  }

  void _next() {
    if (_qi < _questions.length - 1) {
      setState(() {
        _qi++;
        _answered = false;
        _pickedItem = null;
        _pickedRoom = null;
        _picked.clear();
      });
      return;
    }
    final stars = Level.starsFor(_correct, _questions.length);
    ProgressScope.read(context).recordResult(widget.level.number, stars);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ResultScreen(
        level: widget.level,
        correct: _correct,
        total: _questions.length,
        stars: stars,
        missed: _missed,
        orderCorrect: _orderCorrect,
        studyTime: widget.studyTime,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final q = _q;
    final orderReady = q is OrderQuestion && _picked.length == q.shown.length;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
          child: Column(children: [
            TopBar(title: 'Level ${widget.level.number} · Recall', step: _qi + 1, total: _questions.length),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_qi),
                    child: switch (q) {
                      WhatQuestion() => _buildWhat(q),
                      WhereQuestion() => _buildWhere(q),
                      OrderQuestion() => _buildOrder(q),
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: double.infinity,
                child: _answered
                    ? FilledButton(
                        onPressed: _next,
                        child: Text(_qi == _questions.length - 1 ? 'See results' : 'Next question'),
                      )
                    : q is OrderQuestion
                        ? FilledButton(
                            onPressed: orderReady ? () => _checkOrder(q) : null,
                            child: const Text('Check order'),
                          )
                        : const SizedBox(height: 56),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _prompt(String eyebrow, String title) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(eyebrow.toUpperCase(),
          style: text.labelMedium?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800, color: scheme.primary)),
      const SizedBox(height: 6),
      Text(title, style: text.headlineSmall),
    ]);
  }

  Widget _feedback(Placement target) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final color = _wasRight ? scheme.good : scheme.bad;
    return AnimatedOpacity(
      opacity: _answered ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(_wasRight ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: _wasRight ? 'Yes! ' : 'Not quite. ',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                TextSpan(text: '${target.story} (${target.room.name})'),
              ]),
              style: text.bodyMedium,
            ),
          ),
        ]),
      ),
    );
  }

  // "What was inside the fridge?"
  Widget _buildWhat(WhatQuestion q) {
    final scheme = Theme.of(context).colorScheme;
    final t = q.target;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _prompt('${t.room.emoji} ${t.room.name}', 'What was ${t.spot}?'),
      const SizedBox(height: 20),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in q.options)
              _ChoiceTile(
                emoji: item.emoji,
                label: item.name,
                color: !_answered
                    ? null
                    : item == t.item
                        ? scheme.good
                        : item == _pickedItem
                            ? scheme.bad
                            : null,
                dimmed: _answered && item != t.item && item != _pickedItem,
                onTap: _answered
                    ? null
                    : () {
                        _pickedItem = item;
                        _resolve(item == t.item, target: t);
                      },
              ),
          ],
        ),
      ),
      _feedback(t),
    ]);
  }

  // "Where did you leave the giraffe?"
  Widget _buildWhere(WhereQuestion q) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = q.target;
    final correctRoom = rooms.indexOf(t.room);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: _prompt('Tap the room', 'Where did you leave the ${t.item.name.toLowerCase()}?')),
        const SizedBox(width: 12),
        Text(t.item.emoji, style: const TextStyle(fontSize: 52)),
      ]),
      const SizedBox(height: 16),
      Expanded(
        child: Center(
          child: FloorPlan(
            onTapRoom: _answered
                ? null
                : (room) {
                    _pickedRoom = room;
                    _resolve(room == correctRoom, target: t);
                  },
            marks: !_answered
                ? const {}
                : {
                    if (_pickedRoom != null && _pickedRoom != correctRoom) _pickedRoom!: scheme.bad,
                    correctRoom: scheme.good,
                  },
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (_answered)
        _feedback(t)
      else
        Text('Picture yourself walking the route again.',
            textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
    ]);
  }

  void _checkOrder(OrderQuestion q) {
    final answer = q.answer;
    var right = true;
    for (var i = 0; i < answer.length; i++) {
      if (_picked[i] != answer[i]) right = false;
    }
    _orderCorrect = right;
    _resolve(right);
  }

  // "Tap these in the order you walked past them."
  Widget _buildOrder(OrderQuestion q) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final answer = q.answer;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _prompt('Final question', 'Tap these in the order you walked past them'),
      const SizedBox(height: 20),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final p in q.shown)
              Builder(builder: (context) {
                final pos = _picked.indexOf(p);
                final rightPos = answer.indexOf(p);
                return _ChoiceTile(
                  emoji: p.item.emoji,
                  label: p.item.name,
                  badge: _answered ? '${rightPos + 1}' : (pos >= 0 ? '${pos + 1}' : null),
                  color: _answered ? (pos == rightPos ? scheme.good : scheme.bad) : (pos >= 0 ? scheme.primary : null),
                  onTap: _answered
                      ? null
                      : () => setState(() {
                            // Tapping a picked item undoes it and everything after it.
                            if (pos >= 0) {
                              _picked.removeRange(pos, _picked.length);
                            } else {
                              _picked.add(p);
                            }
                          }),
                );
              }),
          ],
        ),
      ),
      if (_answered)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (_wasRight ? scheme.good : scheme.bad).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _wasRight
                ? 'Perfect order! The route did the work for you.'
                : 'The numbers now show the real order: ${answer.map((p) => p.room.name).join(' → ')}.',
            style: text.bodyMedium,
          ),
        )
      else
        Text('Tap a numbered one again to undo.',
            textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
    ]);
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.emoji,
    required this.label,
    this.color,
    this.badge,
    this.dimmed = false,
    this.onTap,
  });

  final String emoji;
  final String label;
  final Color? color;
  final String? badge;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = color;
    return AnimatedOpacity(
      opacity: dimmed ? .45 : 1,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: c == null ? scheme.surfaceContainerHigh : Color.alphaBlend(c.withValues(alpha: .16), scheme.surfaceContainerHigh),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c ?? Colors.transparent, width: 2.5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Stack(children: [
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 4),
                  Text(label, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
              if (badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: c ?? scheme.primary,
                    child: Text(badge!,
                        style: text.labelLarge?.copyWith(color: scheme.surface, fontWeight: FontWeight.w800)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
