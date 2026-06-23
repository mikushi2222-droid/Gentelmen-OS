import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';
import 'package:gentleman_os/features/health/domain/lab_ocr_parser.dart';

void main() {
  group('matchMarkerType', () {
    test('сопоставляет русские названия и аббревиатуры', () {
      expect(matchMarkerType('Тестостерон общий'),
          HealthMarkerType.testosteroneTotal);
      expect(matchMarkerType('Тестостерон свободный'),
          HealthMarkerType.testosteroneFree);
      expect(matchMarkerType('ГСПГ'), HealthMarkerType.shbg);
      expect(matchMarkerType('Витамин D (25-OH)'), HealthMarkerType.vitaminD);
      expect(matchMarkerType('Глюкоза'), HealthMarkerType.glucose);
      expect(matchMarkerType('HbA1c'), HealthMarkerType.hba1c);
      expect(matchMarkerType('ТТГ'), HealthMarkerType.tsh);
      expect(matchMarkerType('ЛПНП'), HealthMarkerType.ldl);
    });

    test('свободный тестостерон не путается с общим (порядок проверок)', () {
      expect(matchMarkerType('Free testosterone'),
          HealthMarkerType.testosteroneFree);
      expect(matchMarkerType('Testosterone'),
          HealthMarkerType.testosteroneTotal);
    });

    test('нечитаемое/неизвестное название → null', () {
      expect(matchMarkerType('Бариевый показатель XYZ'), isNull);
      expect(matchMarkerType(''), isNull);
    });
  });

  group('parseLabResults', () {
    test('разбирает чистый JSON-массив', () {
      const content =
          '[{"markerName":"Тестостерон общий","value":18.7,"unit":"нмоль/л",'
          '"takenAt":"2026-01-15","confidence":0.9},'
          '{"markerName":"Витамин D","value":22,"unit":"нг/мл"}]';
      final drafts = parseLabResults(content);
      expect(drafts, hasLength(2));

      final t = drafts.first;
      expect(t.type, HealthMarkerType.testosteroneTotal);
      expect(t.value, 18.7);
      expect(t.unit, 'нмоль/л');
      expect(t.takenAt, DateTime(2026, 1, 15));
      expect(t.confidence, 0.9);
      expect(t.unitMatches, isTrue);

      final d = drafts[1];
      expect(d.type, HealthMarkerType.vitaminD);
      expect(d.value, 22);
      expect(d.takenAt, isNull);
    });

    test('снимает markdown-ограждение ```json', () {
      const content = '```json\n'
          '[{"markerName":"Глюкоза","value":"5,4","unit":"ммоль/л"}]\n'
          '```';
      final drafts = parseLabResults(content);
      expect(drafts, hasLength(1));
      expect(drafts.single.type, HealthMarkerType.glucose);
      expect(drafts.single.value, 5.4); // запятая → точка
    });

    test('поддерживает объект-обёртку results', () {
      const content =
          '{"results":[{"marker":"ТТГ","value":2.1,"unit":"мМЕ/л"}]}';
      final drafts = parseLabResults(content);
      expect(drafts, hasLength(1));
      expect(drafts.single.type, HealthMarkerType.tsh);
    });

    test('пропускает строки без сопоставленного типа или значения', () {
      const content = '[{"markerName":"Неведомый показатель","value":1},'
          '{"markerName":"Глюкоза","value":"н/д"},'
          '{"markerName":"Ферритин","value":120,"unit":"нг/мл"}]';
      final drafts = parseLabResults(content);
      expect(drafts, hasLength(1));
      expect(drafts.single.type, HealthMarkerType.ferritin);
    });

    test('дата в формате дд.мм.гггг распознаётся', () {
      const content =
          '[{"markerName":"ПСА","value":1.2,"takenAt":"15.01.2026"}]';
      final drafts = parseLabResults(content);
      expect(drafts.single.takenAt, DateTime(2026, 1, 15));
    });

    test('confidence в процентах нормализуется в 0..1', () {
      const content =
          '[{"markerName":"Глюкоза","value":5.0,"confidence":85}]';
      final drafts = parseLabResults(content);
      expect(drafts.single.confidence, closeTo(0.85, 1e-9));
    });

    test('битый JSON → пустой список (деградация на ручной ввод)', () {
      expect(parseLabResults('не json вовсе'), isEmpty);
      expect(parseLabResults(''), isEmpty);
      expect(parseLabResults('[{"markerName": '), isEmpty);
    });

    test('status и unitMatches вычисляются из домена', () {
      const content =
          '[{"markerName":"Витамин D","value":15,"unit":"мкг/л"}]';
      final draft = parseLabResults(content).single;
      // 15 < нижней границы 30 → не норма.
      expect(draft.status, isNot(HealthStatus.normal));
      // мкг/л != нг/мл → единица не совпадает (повод предупредить).
      expect(draft.unitMatches, isFalse);
    });
  });

  group('keepLatestPerType', () {
    test('оставляет по одному актуальному значению на тип (по дате)', () {
      final drafts = [
        LabResultDraft(
          type: HealthMarkerType.testosteroneTotal,
          value: 16.1,
          takenAt: DateTime(2024, 5, 1),
        ),
        LabResultDraft(
          type: HealthMarkerType.testosteroneTotal,
          value: 18.7,
          takenAt: DateTime(2026, 1, 15),
        ),
        const LabResultDraft(
          type: HealthMarkerType.glucose,
          value: 5.2,
        ),
      ];
      final kept = keepLatestPerType(drafts);
      expect(kept, hasLength(2));
      final t = kept.firstWhere(
          (d) => d.type == HealthMarkerType.testosteroneTotal);
      expect(t.value, 18.7); // позднее по дате
    });

    test('черновик с датой важнее черновика без даты', () {
      final drafts = [
        const LabResultDraft(
          type: HealthMarkerType.glucose,
          value: 9.9,
        ),
        LabResultDraft(
          type: HealthMarkerType.glucose,
          value: 5.0,
          takenAt: DateTime(2026, 1, 1),
        ),
      ];
      final kept = keepLatestPerType(drafts);
      expect(kept.single.value, 5.0);
    });

    test('без дат — по уверенности', () {
      final drafts = [
        const LabResultDraft(
          type: HealthMarkerType.ferritin,
          value: 100,
          confidence: 0.4,
        ),
        const LabResultDraft(
          type: HealthMarkerType.ferritin,
          value: 120,
          confidence: 0.9,
        ),
      ];
      expect(keepLatestPerType(drafts).single.value, 120);
    });
  });
}
