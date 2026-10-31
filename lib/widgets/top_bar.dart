import 'package:flutter/material.dart';

/// Close button, title and a step counter, with a progress bar underneath.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.step, required this.total});

  final String title;
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          IconButton(
            tooltip: 'Back to home',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
          Text('$step / $total', style: text.titleSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(width: 8),
        ]),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: step / total),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
