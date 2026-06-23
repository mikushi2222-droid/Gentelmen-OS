import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/knowledge/domain/reading_time.dart';

void main() {
  group('readingMinutes', () {
    test('пустой текст → минимум 1 минута', () {
      expect(readingMinutes(''), 1);
      expect(readingMinutes('   \n  '), 1);
    });

    test('короткий текст округляется вверх до 1', () {
      expect(readingMinutes('одно два три слова'), 1);
    });

    test('200 слов при 200 сл/мин → 1 минута', () {
      final text = List.filled(200, 'слово').join(' ');
      expect(readingMinutes(text), 1);
    });

    test('250 слов → 2 минуты (округление вверх)', () {
      final text = List.filled(250, 'слово').join(' ');
      expect(readingMinutes(text), 2);
    });

    test('очень длинный текст зажимается в 99', () {
      final text = List.filled(40000, 'слово').join(' ');
      expect(readingMinutes(text), 99);
    });

    test('настраиваемая скорость чтения', () {
      final text = List.filled(300, 'слово').join(' ');
      expect(readingMinutes(text, wordsPerMinute: 100), 3);
    });
  });
}
