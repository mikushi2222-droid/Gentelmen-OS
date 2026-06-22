import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/dashboard/domain/sub_scores.dart';

void main() {
  group('SubScores', () {
    test('all возвращает четыре под-оценки', () {
      const s = SubScores(style: 80, health: 70, biohacking: 60, discipline: 90);
      expect(s.all.map((e) => e.name),
          containsAll(['Стиль', 'Здоровье', 'Биохакинг', 'Дисциплина']));
    });

    test('weakest — звено с минимальным значением', () {
      const s = SubScores(style: 80, health: 55, biohacking: 60, discipline: 90);
      expect(s.weakest.name, 'Здоровье');
      expect(s.weakest.value, 55);
    });
  });

  group('dailyTip', () {
    test('совет вытекает из слабейшего звена', () {
      const weakDiscipline =
          SubScores(style: 90, health: 90, biohacking: 90, discipline: 30);
      expect(dailyTip(weakDiscipline), contains('привычк'));

      const weakStyle =
          SubScores(style: 20, health: 90, biohacking: 90, discipline: 90);
      expect(dailyTip(weakStyle), contains('образ'));
    });

    test('совет непустой при любых данных', () {
      const s = SubScores(style: 50, health: 50, biohacking: 50, discipline: 50);
      expect(dailyTip(s), isNotEmpty);
    });
  });
}
