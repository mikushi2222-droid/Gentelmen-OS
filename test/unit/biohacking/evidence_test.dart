import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/biohacking/domain/evidence.dart';

void main() {
  group('EvidenceRating', () {
    test('code и label', () {
      expect(EvidenceRating.a.code, 'A');
      expect(EvidenceRating.b.code, 'B');
      expect(EvidenceRating.c.code, 'C');
      expect(EvidenceRating.a.label, contains('много'));
    });

    test('fromCode распознаёт регистр', () {
      expect(EvidenceRating.fromCode('a'), EvidenceRating.a);
      expect(EvidenceRating.fromCode('B'), EvidenceRating.b);
      expect(EvidenceRating.fromCode('c'), EvidenceRating.c);
    });

    test('неизвестный код → C (консервативно)', () {
      expect(EvidenceRating.fromCode('?'), EvidenceRating.c);
      expect(EvidenceRating.fromCode(''), EvidenceRating.c);
    });
  });
}
