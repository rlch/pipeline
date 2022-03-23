import 'dart:math';

import 'package:pipeline/pipeline.dart';
import 'package:test/test.dart';

void main() {
  final types = [
    1,
    1.0,
    null,
    'foo',
    [],
    {},
    true,
    DateTime(0),
    () => null,
  ];
  Object? randType() => types[Random().nextInt(types.length)];

  group('pipeline', () {
    test('null initialValue', () {
      expect(Pipeline.start(null, (_) => 'works').run(), equals('works'));
    });

    test('chain', () {
      expect(
          Pipeline.start<String, String>('foo', (from) => from + 'bar')
              .next((from) => from.length)
              .run(),
          equals(6));
    });

    test('long chain', () {
      int increment(int from) => ++from;

      var pipeline = Pipeline.start(0, increment);
      for (var i = 0; i < 999; i++) {
        pipeline = pipeline.next(increment);
      }

      expect(pipeline.run(), equals(1000));
    });

    test('random types', () {
      Object? rand<From>(From from) => randType();
      var pipeline = Pipeline.start(null, rand);
      for (var i = 0; i < 999; i++) {
        pipeline = pipeline.next(rand);
      }

      expect(pipeline.run(), anyOf(types));
    });

    test('future', () async {
      int hits = 0;
      Future<void> Function(Object?) wait(int ms) => (obj) =>
          Future.delayed(Duration(milliseconds: ms)).then((_) => hits++);

      var pipeline = Pipeline.start(null, wait(10));
      for (var i = 0; i < 9; i++) {
        pipeline = pipeline.next(wait(10));
      }

      await pipeline.run();
      expect(hits, 10);

      for (var i = 0; i < 10; i++) {
        pipeline = pipeline.next(wait(10));
      }

      await pipeline.run();
      expect(hits, 30);
    });
  });
}
