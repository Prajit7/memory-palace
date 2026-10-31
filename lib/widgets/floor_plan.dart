import 'package:flutter/material.dart';

import '../data.dart';

/// The house seen from above. The walked route is drawn as a line through the
/// doorways between rooms.
class FloorPlan extends StatelessWidget {
  const FloorPlan({
    super.key,
    this.current,
    this.visited = const {},
    this.routeTo = -1,
    this.onTapRoom,
    this.marks = const {},
  });

  /// Room to highlight as "you are here".
  final int? current;
  final Set<int> visited;

  /// Draw the route from the first room up to this room index.
  final int routeTo;
  final ValueChanged<int>? onTapRoom;

  /// Answer feedback: room index → color.
  final Map<int, Color> marks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, box) {
        final cell = box.maxWidth / 3;
        Offset centerOf(int i) => Offset((rooms[i].col + .5) * cell, (rooms[i].row + .5) * cell);
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Stack(children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoutePainter([for (var i = 0; i <= routeTo; i++) centerOf(i)], scheme.primary),
              ),
            ),
            for (var i = 0; i < rooms.length; i++)
              Positioned(
                left: rooms[i].col * cell,
                top: rooms[i].row * cell,
                width: cell,
                height: cell,
                child: Padding(
                  padding: EdgeInsets.all(cell * .06),
                  child: _RoomTile(
                    room: rooms[i],
                    size: cell,
                    isCurrent: current == i,
                    isVisited: visited.contains(i),
                    mark: marks[i],
                    onTap: onTapRoom == null ? null : () => onTapRoom!(i),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.size,
    required this.isCurrent,
    required this.isVisited,
    required this.mark,
    required this.onTap,
  });

  final Room room;
  final double size;
  final bool isCurrent;
  final bool isVisited;
  final Color? mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = mark != null
        ? Color.alphaBlend(mark!.withValues(alpha: .2), scheme.surfaceContainerHighest)
        : isCurrent
            ? scheme.primaryContainer
            : isVisited
                ? scheme.secondaryContainer
                : scheme.surfaceContainerHighest;
    final borderColor = mark ?? (isCurrent ? scheme.primary : Colors.transparent);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isCurrent ? 1.15 : 1,
                duration: const Duration(milliseconds: 250),
                child: Text(room.emoji, style: TextStyle(fontSize: size * .25)),
              ),
              SizedBox(height: size * .03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: (size * .1).clamp(9, 13).toDouble(),
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.points, this.color);

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.points.length != points.length || old.color != color;
}
