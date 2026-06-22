// Доменная модель мужского здоровья.
// ВАЖНО: это просвещение и трекинг, НЕ медицинская диагностика.
// Референсные диапазоны — усреднённые для взрослого мужчины; интерпретирует
// только врач. Все значения проверяются чистыми функциями (юнит-тестируемо).

/// Статус показателя относительно референсного диапазона.
enum HealthStatus { normal, warning, risk, unknown }

extension HealthStatusX on HealthStatus {
  String get label => switch (this) {
        HealthStatus.normal => 'Норма',
        HealthStatus.warning => 'Внимание',
        HealthStatus.risk => 'Риск',
        HealthStatus.unknown => 'Нет данных',
      };
}

/// Ключевые мужские маркеры здоровья.
enum HealthMarkerType {
  testosteroneTotal,
  testosteroneFree,
  shbg,
  psa,
  vitaminD,
  ferritin,
  ldl,
  hdl,
  glucose,
  hba1c,
  tsh,
  bloodPressureSys,
  bloodPressureDia,
  restingHeartRate,
  bodyFat,
  sleepHours;

  String get label => switch (this) {
        HealthMarkerType.testosteroneTotal => 'Тестостерон общий',
        HealthMarkerType.testosteroneFree => 'Тестостерон свободный',
        HealthMarkerType.shbg => 'ГСПГ (SHBG)',
        HealthMarkerType.psa => 'ПСА (PSA)',
        HealthMarkerType.vitaminD => 'Витамин D',
        HealthMarkerType.ferritin => 'Ферритин',
        HealthMarkerType.ldl => 'Холестерин ЛПНП',
        HealthMarkerType.hdl => 'Холестерин ЛПВП',
        HealthMarkerType.glucose => 'Глюкоза',
        HealthMarkerType.hba1c => 'Гликир. гемоглобин',
        HealthMarkerType.tsh => 'ТТГ',
        HealthMarkerType.bloodPressureSys => 'Давление (верхн.)',
        HealthMarkerType.bloodPressureDia => 'Давление (нижн.)',
        HealthMarkerType.restingHeartRate => 'Пульс покоя',
        HealthMarkerType.bodyFat => '% жира',
        HealthMarkerType.sleepHours => 'Сон',
      };

  String get unit => switch (this) {
        HealthMarkerType.testosteroneTotal => 'нмоль/л',
        HealthMarkerType.testosteroneFree => 'нмоль/л',
        HealthMarkerType.shbg => 'нмоль/л',
        HealthMarkerType.psa => 'нг/мл',
        HealthMarkerType.vitaminD => 'нг/мл',
        HealthMarkerType.ferritin => 'нг/мл',
        HealthMarkerType.ldl => 'ммоль/л',
        HealthMarkerType.hdl => 'ммоль/л',
        HealthMarkerType.glucose => 'ммоль/л',
        HealthMarkerType.hba1c => '%',
        HealthMarkerType.tsh => 'мМЕ/л',
        HealthMarkerType.bloodPressureSys => 'мм рт.ст.',
        HealthMarkerType.bloodPressureDia => 'мм рт.ст.',
        HealthMarkerType.restingHeartRate => 'уд/мин',
        HealthMarkerType.bodyFat => '%',
        HealthMarkerType.sleepHours => 'ч',
      };

  /// Референсный диапазон нормы [min, max]; null — граница не задана.
  ({double? min, double? max}) get reference => switch (this) {
        HealthMarkerType.testosteroneTotal => (min: 8.6, max: 29.0),
        HealthMarkerType.testosteroneFree => (min: 0.2, max: 0.62),
        HealthMarkerType.shbg => (min: 18.3, max: 54.1),
        HealthMarkerType.psa => (min: 0.0, max: 4.0),
        HealthMarkerType.vitaminD => (min: 30.0, max: 100.0),
        HealthMarkerType.ferritin => (min: 30.0, max: 400.0),
        HealthMarkerType.ldl => (min: 0.0, max: 3.0),
        HealthMarkerType.hdl => (min: 1.0, max: null),
        HealthMarkerType.glucose => (min: 3.9, max: 5.5),
        HealthMarkerType.hba1c => (min: 4.0, max: 5.6),
        HealthMarkerType.tsh => (min: 0.4, max: 4.0),
        HealthMarkerType.bloodPressureSys => (min: 90.0, max: 120.0),
        HealthMarkerType.bloodPressureDia => (min: 60.0, max: 80.0),
        HealthMarkerType.restingHeartRate => (min: 50.0, max: 80.0),
        HealthMarkerType.bodyFat => (min: 8.0, max: 20.0),
        HealthMarkerType.sleepHours => (min: 7.0, max: 9.0),
      };

  /// Рекомендованный интервал проверки в месяцах.
  int get checkIntervalMonths => switch (this) {
        HealthMarkerType.testosteroneTotal => 6,
        HealthMarkerType.testosteroneFree => 6,
        HealthMarkerType.shbg => 6,
        HealthMarkerType.psa => 12,
        HealthMarkerType.vitaminD => 6,
        HealthMarkerType.ferritin => 6,
        HealthMarkerType.ldl => 12,
        HealthMarkerType.hdl => 12,
        HealthMarkerType.glucose => 3,
        HealthMarkerType.hba1c => 3,
        HealthMarkerType.tsh => 12,
        HealthMarkerType.bloodPressureSys => 1,
        HealthMarkerType.bloodPressureDia => 1,
        HealthMarkerType.restingHeartRate => 1,
        HealthMarkerType.bodyFat => 3,
        HealthMarkerType.sleepHours => 1,
      };

  /// Краткая подсказка о маркере.
  String get hint => switch (this) {
        HealthMarkerType.testosteroneTotal =>
          'Главный мужской гормон: энергия, либидо, мышцы.',
        HealthMarkerType.psa =>
          'Скрининг простаты. Рост — повод обратиться к урологу.',
        HealthMarkerType.vitaminD =>
          'Влияет на тестостерон, иммунитет, настроение.',
        HealthMarkerType.glucose =>
          'Контроль сахара — профилактика диабета.',
        HealthMarkerType.sleepHours =>
          'Сон 7–9 ч поддерживает гормональный баланс.',
        _ => 'Отслеживайте динамику и обсуждайте с врачом.',
      };
}

/// Статус значения относительно референса.
/// [warningMargin] — доля от диапазона, в пределах которой выход за границу
/// считается «вниманием», а не «риском».
HealthStatus markerStatus(
  HealthMarkerType type,
  double value, {
  double warningMargin = 0.15,
}) {
  final ref = type.reference;
  final min = ref.min;
  final max = ref.max;

  // Ширина диапазона для расчёта warning-полосы.
  final span = (min != null && max != null)
      ? (max - min)
      : (max ?? min ?? 1.0).abs();
  final margin = span * warningMargin;

  if (min != null && value < min) {
    return value >= min - margin ? HealthStatus.warning : HealthStatus.risk;
  }
  if (max != null && value > max) {
    return value <= max + margin ? HealthStatus.warning : HealthStatus.risk;
  }
  return HealthStatus.normal;
}

/// Агрегированный «Индекс здоровья» (0..100): доля маркеров в норме,
/// где warning засчитывается за половину. Учитываются только введённые маркеры.
double healthIndex(Map<HealthMarkerType, double> latestByType) {
  if (latestByType.isEmpty) return 0.0;
  var sum = 0.0;
  for (final e in latestByType.entries) {
    sum += switch (markerStatus(e.key, e.value)) {
      HealthStatus.normal => 1.0,
      HealthStatus.warning => 0.5,
      HealthStatus.risk => 0.0,
      HealthStatus.unknown => 0.0,
    };
  }
  return (sum / latestByType.length * 100).clamp(0.0, 100.0);
}
