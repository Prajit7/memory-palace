import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_palace/data.dart';
import 'package:memory_palace/game.dart';

void main() {
  test('every level places the right number of unique items in route order', () {
    for (var n = 1; n <= Level.maxLevel; n++) {
      final level = Level.generate(n, random: Random(n));
      final p = level.placements;
      expect(p.length, Level.itemCount(n));
      expect(p.map((e) => e.item).toSet().length, p.length);
      expect(p.map((e) => '${e.room.name}|${e.spot}').toSet().length, p.length);
      for (var i = 1; i < p.length; i++) {
        expect(rooms.indexOf(p[i].room) >= rooms.indexOf(p[i - 1].room), isTrue);
      }
    }
  });

  test('quiz has one question per item plus an order question', () {
    final level = Level.generate(3, random: Random(1));
    final quiz = level.buildQuiz(random: Random(2));
    expect(quiz.length, level.placements.length + 1);
    expect(quiz.last, isA<OrderQuestion>());
    for (final q in quiz.whereType<WhatQuestion>()) {
      expect(q.options.length, 4);
      expect(q.options, contains(q.target.item));
    }
  });

  test('stars thresholds', () {
    expect(Level.starsFor(10, 10), 3);
    expect(Level.starsFor(8, 10), 2);
    expect(Level.starsFor(6, 10), 1);
    expect(Level.starsFor(5, 10), 0);
  });
}
