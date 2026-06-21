import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/services/achievement_catalog.dart';

void main() {
  group('Achv каталог достижений', () {
    test('коды уникальны', () {
      final codes = Achv.all.map((e) => e.$1).toList();
      expect(codes.toSet().length, codes.length,
          reason: 'Дублирующиеся коды достижений');
    });

    test('заголовки и описания непустые', () {
      for (final (code, title, desc) in Achv.all) {
        expect(code.trim(), isNotEmpty);
        expect(title.trim(), isNotEmpty, reason: 'Пустой заголовок для $code');
        expect(desc.trim(), isNotEmpty, reason: 'Пустое описание для $code');
      }
    });

    test('все именованные константы присутствуют в каталоге сидинга', () {
      // Любой код, разблокируемый сервисом, обязан сидиться в БД, иначе
      // достижение не существует и unlock молча ничего не делает.
      const referenced = {
        Achv.firstItem,
        Achv.wardrobe10,
        Achv.wardrobe25,
        Achv.firstOutfit,
        Achv.bookworm5,
        Achv.bookworm10,
        Achv.streak7,
        Achv.streak30,
        Achv.level5,
        Achv.level10,
        Achv.measureLogged,
        Achv.budgetMaster,
      };
      final seeded = Achv.all.map((e) => e.$1).toSet();
      expect(seeded.containsAll(referenced), isTrue,
          reason: 'Не засеяны коды: ${referenced.difference(seeded)}');
    });
  });
}
