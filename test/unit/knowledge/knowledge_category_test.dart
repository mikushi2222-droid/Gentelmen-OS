import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';

void main() {
  // Сид-данные в app_database задают категорию статьи ЧИСЛОВЫМ индексом
  // (например discipline-habits → 8). Если порядок значений enum изменить,
  // статьи молча попадут не в ту категорию. Этот тест фиксирует контракт.
  group('KnowledgeCategory индексы (контракт сидинга)', () {
    test('порядок значений совпадает с ожидаемым', () {
      expect(KnowledgeCategory.values.map((e) => e.name).toList(), [
        'style', // 0
        'etiquette', // 1
        'grooming', // 2
        'fabrics', // 3
        'shoes', // 4
        'suits', // 5
        'casual', // 6
        'health', // 7
        'discipline', // 8
        'reading', // 9
      ]);
    });

    test('discipline = 8, reading = 9 (регрессия discipline-habits)', () {
      expect(KnowledgeCategory.values[8], KnowledgeCategory.discipline);
      expect(KnowledgeCategory.values[9], KnowledgeCategory.reading);
    });
  });
}
