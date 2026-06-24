// ignore_for_file: avoid_relative_lib_imports
//
// Requires `dart run build_runner build` before running, because
// app_database.g.dart is generated and not committed.
//
// Run with: flutter test test/unit/db/migration_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/db/app_database.dart';

AppDatabase _openMemory() => AppDatabase(NativeDatabase.memory());

void main() {
  group('AppDatabase migration — schemaVersion 7', () {
    late AppDatabase db;

    setUp(() {
      db = _openMemory();
    });

    tearDown(() async {
      await db.close();
    });

    test('onCreate создаёт схему версии 7', () async {
      // Accessing any table forces onCreate to run.
      final rows = await db.select(db.userProfile).get();
      expect(rows.length, 1); // seedUserProfile inserts exactly one row
    });

    test('сид вставляет начальный профиль пользователя', () async {
      final rows = await db.select(db.userProfile).get();
      expect(rows.length, 1);
    });

    test('сид вставляет достижения', () async {
      final rows = await db.select(db.achievements).get();
      expect(rows.length, greaterThanOrEqualTo(13));
    });

    test('сид вставляет статьи базы знаний', () async {
      final rows = await db.select(db.knowledgeArticles).get();
      expect(rows.length, greaterThan(0));
    });

    test('статья discipline-habits имеет категорию 8', () async {
      final rows = await db.select(db.knowledgeArticles).get();
      final article = rows.where((r) => r.id == 'discipline-habits').toList();
      expect(article, isNotEmpty);
      expect(article.first.category, 8,
          reason: 'v7 migration должна проставить category=8 для discipline-habits');
    });

    test('сид вставляет привычки здоровья', () async {
      final rows = await db.select(db.habits).get();
      expect(rows, isNotEmpty);
    });

    test('таблица healthMarkers существует и пуста', () async {
      final rows = await db.select(db.healthMarkers).get();
      expect(rows, isEmpty);
    });

    test('таблица clothingItems пуста после create', () async {
      final rows = await db.select(db.clothingItems).get();
      expect(rows, isEmpty);
    });

    test('таблица outfits пуста после create', () async {
      final rows = await db.select(db.outfits).get();
      expect(rows, isEmpty);
    });
  });
}
