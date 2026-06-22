import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ScoreRing', () {
    testWidgets('отображает значение счёта', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 75, size: 100),
      ));
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('отображает нулевой счёт', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 0, size: 100),
      ));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('отображает метку, если передана', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 50, size: 100, label: 'SCORE'),
      ));
      expect(find.text('SCORE'), findsOneWidget);
    });

    testWidgets('не падает при score > 100', (tester) async {
      await tester.pumpWidget(_wrap(
        const ScoreRing(score: 150, size: 100),
      ));
      expect(find.text('150'), findsOneWidget);
    });
  });
}
