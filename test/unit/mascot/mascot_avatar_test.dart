import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/widgets/mascot_avatar.dart';

void main() {
  group('moodFromScore', () {
    test('низкий счёт (<30) → neutral', () {
      expect(moodFromScore(0), MascotMood.neutral);
      expect(moodFromScore(29.9), MascotMood.neutral);
    });

    test('средний счёт (30–69) → pleased', () {
      expect(moodFromScore(30), MascotMood.pleased);
      expect(moodFromScore(50), MascotMood.pleased);
      expect(moodFromScore(69.9), MascotMood.pleased);
    });

    test('высокий счёт (>=70) → proud', () {
      expect(moodFromScore(70), MascotMood.proud);
      expect(moodFromScore(100), MascotMood.proud);
    });

    test('границы переключают настроение монотонно', () {
      expect(moodFromScore(29).index, lessThanOrEqualTo(moodFromScore(30).index));
      expect(moodFromScore(69).index, lessThanOrEqualTo(moodFromScore(70).index));
    });
  });

  group('mascotPhrase', () {
    test('фраза непуста для каждого настроения', () {
      for (final mood in MascotMood.values) {
        expect(mascotPhrase(mood), isNotEmpty);
      }
    });

    test('фразы различаются по настроению', () {
      final phrases = MascotMood.values.map(mascotPhrase).toSet();
      expect(phrases.length, MascotMood.values.length);
    });
  });
}
