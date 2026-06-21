import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/rpg_dao.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';
import 'package:uuid/uuid.dart';

class XpService {
  const XpService(this._dao);

  final RpgDao _dao;

  Future<void> award(XpType type, int amount, String reason) async {
    await _dao.addXpEvent(
      XpEventsCompanion(
        id: Value(const Uuid().v4()),
        type: Value(type.index),
        amount: Value(amount),
        reason: Value(reason),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  // Convenience shortcuts
  Future<void> wardrobeItemAdded() =>
      award(XpType.style, 10, 'Добавлена вещь в гардероб');

  Future<void> outfitSaved() =>
      award(XpType.style, 20, 'Создан образ');

  Future<void> articleRead() =>
      award(XpType.reading, 15, 'Прочитана статья');

  Future<void> measurementLogged() =>
      award(XpType.fitness, 10, 'Записан замер');

  Future<void> habitCompleted(String habitTitle) =>
      award(XpType.general, 5, 'Привычка: $habitTitle');
}

final xpServiceProvider = Provider<XpService>(
  (ref) => XpService(ref.watch(rpgDaoProvider)),
);
