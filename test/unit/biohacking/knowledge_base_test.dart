import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/biohacking/domain/knowledge_base.dart';

void main() {
  group('kProtocols', () {
    test('непустые протоколы с шагами и целью', () {
      expect(kProtocols, isNotEmpty);
      for (final p in kProtocols) {
        expect(p.name, isNotEmpty);
        expect(p.goal, isNotEmpty);
        expect(p.steps, isNotEmpty);
      }
    });

    test('есть протокол сна', () {
      expect(kProtocols.any((p) => p.name == 'Сон'), isTrue);
    });
  });

  group('kSupplements', () {
    test('у каждой добавки заполнены поля и есть доказательность', () {
      expect(kSupplements, isNotEmpty);
      for (final s in kSupplements) {
        expect(s.name, isNotEmpty);
        expect(s.dose, isNotEmpty);
        expect(s.risks, isNotEmpty);
        expect(s.interactions, isNotEmpty);
        expect(s.evidence.code, isIn(['A', 'B', 'C']));
      }
    });
  });
}
