import 'package:drift/drift.dart';

/// Запись приёма пищи — текстовая или фотографическая.
/// Основа для V3.1 AI Food Analysis.
@DataClassName('FoodLogsData')
class FoodLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get loggedAt => dateTime()();

  /// Описание еды: «Стейк и картошка» или автозаполнение из AI.
  TextColumn get description => text()();

  /// Приблизительные калории (AI-оценка или ручной ввод).
  IntColumn get kcalEstimate => integer().nullable()();

  /// «likely adequate» / «low» / «high» — текстовая оценка белка из AI.
  TextColumn get proteinEstimate => text().nullable()();

  /// 0=breakfast, 1=lunch, 2=dinner, 3=snack.
  IntColumn get mealType => integer().nullable()();

  /// Путь к локальному фото (временное → documents при сохранении).
  TextColumn get photoPath => text().nullable()();

  /// Сырой JSON-ответ AI для отладки и переразбора.
  TextColumn get aiResponse => text().nullable()();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
