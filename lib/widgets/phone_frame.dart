import 'dart:math';

import 'package:flutter/material.dart';

/// On wide screens (desktop browser) the app sits in a phone-sized column,
/// so it always has the mobile layout. On phones it fills the screen.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static const width = 420.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final height = min(900.0, box.maxHeight - 48);
      if (box.maxWidth < 600 || height < 480) return child;
      final scheme = Theme.of(context).colorScheme;
      final mq = MediaQuery.of(context);
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: [
                BoxShadow(color: scheme.shadow.withValues(alpha: .18), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: MediaQuery(
                data: mq.copyWith(size: Size(width, height), padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
                child: child,
              ),
            ),
          ),
        ),
      );
    });
  }
}
