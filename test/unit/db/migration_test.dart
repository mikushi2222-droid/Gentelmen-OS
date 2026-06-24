// ignore_for_file: avoid_relative_lib_imports
//
// Requires `dart run build_runner build` before running, because
// app_database.g.dart is generated and not committed.
//
// Run with: flutter test test/unit/db/migration_test.dart

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/db/app_database.dart';

AppDatabase _openMemory() => AppDatabase(NativeDatabase.memory());

void main() {
  group('AppDatabase migration — schemaVersion 8', () {
    late AppDatabase db;

    setUp(() {
      db = _openMemory();
    });

    tearDown(() async {
      await db.close();
    });

    test('onCreate создаёт схему версии 8', () async {
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

    test('таблица recoveryLogs существует и пуста', () async {
      final rows = await db.select(db.recoveryLogs).get();
      expect(rows, isEmpty);
    });

    test('таблица dailyCompliances существует и пуста', () async {
      final rows = await db.select(db.dailyCompliances).get();
      expect(rows, isEmpty);
    });

    test('таблица foodLogs существует и пуста', () async {
      final rows = await db.select(db.foodLogs).get();
      expect(rows, isEmpty);
    });

    test('MeasurementLogs имеет поля proteinGrams и hydrationMl', () async {
      await db.into(db.measurementLogs).insert(
            MeasurementLogsCompanion.insert(
              id: '1',
              date: DateTime(2026, 1, 1),
              proteinGrams: const Value(120.5),
              hydrationMl: const Value(2000),
            ),
          );
      final rows = await db.select(db.measurementLogs).get();
      expect(rows.first.proteinGrams, closeTo(120.5, 0.01));
      expect(rows.first.hydrationMl, 2000);
    });
  });
}
