import 'dart:math';

import 'data.dart';

/// One stop on the walk: an item doing something odd at a spot in a room.
class Placement {
  const Placement({
    required this.order,
    required this.room,
    required this.spot,
    required this.item,
    required this.story,
  });

  /// Position along the walk, starting at 0.
  final int order;
  final Room room;
  final String spot;
  final Item item;
  final String story;
}

class Level {
  Level._(this.number, this.placements);

  static const maxLevel = 16;

  /// Level 1 has 5 items, each level adds one, up to 20.
  static int itemCount(int level) => min(4 + level, 20);

  final int number;
  final List<Placement> placements;

  factory Level.generate(int number, {Random? random}) {
    final rng = random ?? Random();
    final count = itemCount(number);
    // Spread items evenly: with 5 items the first 5 rooms get one each,
    // with 20 items every room gets two and the first two rooms get three.
    final base = count ~/ rooms.length;
    final extra = count % rooms.length;
    final items = [...allItems]..shuffle(rng);
    final moves = [...actions]..shuffle(rng);

    final placements = <Placement>[];
    for (var r = 0; r < rooms.length; r++) {
      final room = rooms[r];
      final n = base + (r < extra ? 1 : 0);
      final spots = (List.generate(room.spots.length, (i) => i)..shuffle(rng)).take(n).toList()..sort();
      for (final s in spots) {
        final i = placements.length;
        final item = items[i];
        final spot = room.spots[s];
        placements.add(Placement(
          order: i,
          room: room,
          spot: spot,
          item: item,
          story: '${capitalize(item.phrase)} ${moves[i % moves.length]} $spot.',
        ));
      }
    }
    return Level._(number, placements);
  }

  /// One question per item (what was here / where was this), then one
  /// ordering question.
  List<Question> buildQuiz({Random? random}) {
    final rng = random ?? Random();
    final questions = <Question>[];
    for (final p in [...placements]..shuffle(rng)) {
      if (rng.nextBool()) {
        final others = placements.where((o) => o != p).toList()..shuffle(rng);
        final options = [p.item, ...others.take(3).map((o) => o.item)]..shuffle(rng);
        questions.add(WhatQuestion(p, options));
      } else {
        questions.add(WhereQuestion(p));
      }
    }
    if (placements.length >= 4) {
      questions.add(OrderQuestion(([...placements]..shuffle(rng)).take(4).toList()));
    }
    return questions;
  }

  static int starsFor(int correct, int total) {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 1) return 3;
    if (ratio >= .8) return 2;
    if (ratio >= .6) return 1;
    return 0;
  }
}

sealed class Question {
  const Question();
}

/// "What was inside the fridge?" Pick one of four items.
class WhatQuestion extends Question {
  const WhatQuestion(this.target, this.options);
  final Placement target;
  final List<Item> options;
}

/// "Where did you leave the giraffe?" Tap a room on the floor plan.
class WhereQuestion extends Question {
  const WhereQuestion(this.target);
  final Placement target;
}

/// Tap four items in the order you walked past them.
class OrderQuestion extends Question {
  const OrderQuestion(this.shown);
  final List<Placement> shown;
  List<Placement> get answer => [...shown]..sort((a, b) => a.order.compareTo(b.order));
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
