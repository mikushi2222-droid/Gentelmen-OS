// Разбор ответа Router AI при распознавании фото бланка анализов.
// ВАЖНО: распознавание — черновое; значения проверяет пользователь, а
// интерпретирует врач. Это просвещение и трекинг, НЕ диагностика.
//
// Чистый domain-слой: без Flutter и drift, поэтому полностью юнит-тестируем.

import 'dart:convert';

import 'package:gentleman_os/features/health/domain/health_marker.dart';

/// Черновик распознанного показателя анализа — кандидат на сохранение.
/// Пользователь подтверждает/правит его перед записью в БД.
class LabResultDraft {
  const LabResultDraft({
    required this.type,
    required this.value,
    this.unit = '',
    this.takenAt,
    this.confidence,
    this.rawName,
  });

  /// Сопоставленный тип маркера.
  final HealthMarkerType type;

  /// Числовое значение показателя.
  final double value;

  /// Единица из бланка (может отличаться от [HealthMarkerType.unit]).
  final String unit;

  /// Дата забора анализа, если распозналась.
  final DateTime? takenAt;

  /// Уверенность распознавания 0..1, если модель её вернула.
  final double? confidence;

  /// Исходное название показателя из бланка (для подсказки пользователю).
  final String? rawName;

  /// Статус относительно референса (зоны Норма/Внимание/Риск).
  HealthStatus get status => markerStatus(type, value);

  /// Совпадает ли распознанная единица с ожидаемой для типа (нормализованно).
  /// Пустая единица считается совпадающей (не на что ругаться).
  bool get unitMatches =>
      unit.trim().isEmpty || _normUnit(unit) == _normUnit(type.unit);
}

/// Парсит ответ модели (текст с JSON, возможно в markdown-ограждении) в список
/// черновиков. Любая ошибка разбора → пустой список (вызывающий код деградирует
/// на ручной ввод, приложение не падает).
List<LabResultDraft> parseLabResults(String aiContent) {
  final jsonText = _extractJson(aiContent);
  if (jsonText == null) return const [];

  Object? decoded;
  try {
    decoded = jsonDecode(jsonText);
  } on FormatException {
    return const [];
  }

  final items = _asItemList(decoded);
  final result = <LabResultDraft>[];
  for (final raw in items) {
    if (raw is! Map) continue;
    final draft = _draftFromMap(raw);
    if (draft != null) result.add(draft);
  }
  return result;
}

LabResultDraft? _draftFromMap(Map<dynamic, dynamic> m) {
  final name = _firstString(m, const ['markerName', 'name', 'marker', 'показатель']);
  if (name == null) return null;
  final type = matchMarkerType(name);
  if (type == null) return null;

  final value = _parseNum(_firstValue(m, const ['value', 'значение', 'result']));
  if (value == null) return null;

  final unit = _firstString(m, const ['unit', 'units', 'единица', 'ед']) ?? '';
  final takenAt =
      _parseDate(_firstValue(m, const ['takenAt', 'date', 'дата']));
  final confidence =
      _parseConfidence(_firstValue(m, const ['confidence', 'уверенность']));

  return LabResultDraft(
    type: type,
    value: value,
    unit: unit.trim(),
    takenAt: takenAt,
    confidence: confidence,
    rawName: name.trim(),
  );
}

/// Сопоставляет название показателя из бланка с [HealthMarkerType].
/// Терпимо к регистру, пробелам, RU/EN-синонимам и аббревиатурам.
/// Возвращает null, если уверенного сопоставления нет.
HealthMarkerType? matchMarkerType(String rawName) {
  final n = _normName(rawName);
  if (n.isEmpty) return null;

  bool has(String s) => n.contains(s);

  // Более специфичные проверки идут раньше общих (свободный → до общего).
  if (has('свободн') && has('тестостерон')) {
    return HealthMarkerType.testosteroneFree;
  }
  if (has('free') && has('testosteron')) {
    return HealthMarkerType.testosteroneFree;
  }
  if (has('тестостерон') || has('testosteron')) {
    return HealthMarkerType.testosteroneTotal;
  }
  if (has('гспг') || has('shbg') || has('глобулин связыва')) {
    return HealthMarkerType.shbg;
  }
  if (has('пса') || has('psa') || has('простатспециф')) {
    return HealthMarkerType.psa;
  }
  if (has('витамин d') || has('витамин д') || has('vitamin d') ||
      (has('25') && has('oh'))) {
    return HealthMarkerType.vitaminD;
  }
  if (has('ферритин') || has('ferritin')) return HealthMarkerType.ferritin;
  if (has('лпнп') || has('ldl') || has('низкой плотности')) {
    return HealthMarkerType.ldl;
  }
  if (has('лпвп') || has('hdl') || has('высокой плотности')) {
    return HealthMarkerType.hdl;
  }
  if (has('hba1c') || has('гликирован') || has('гликозилирован')) {
    return HealthMarkerType.hba1c;
  }
  if (has('глюкоз') || has('glucose') || has('сахар крови')) {
    return HealthMarkerType.glucose;
  }
  if (has('ттг') || has('tsh') || has('тиреотроп')) {
    return HealthMarkerType.tsh;
  }
  if (has('систол') || has('верхнее давл') || has('sys')) {
    return HealthMarkerType.bloodPressureSys;
  }
  if (has('диастол') || has('нижнее давл') || has('dia')) {
    return HealthMarkerType.bloodPressureDia;
  }
  if (has('пульс') || has('чсс') || has('heart rate') || has('пульс покоя')) {
    return HealthMarkerType.restingHeartRate;
  }
  if (has('жир') || has('body fat')) return HealthMarkerType.bodyFat;
  return null;
}

// ── helpers ─────────────────────────────────────────────────────────────────

/// Достаёт JSON из текста: снимает markdown-огрраждение и берёт фрагмент от
/// первой `[`/`{` до парной закрывающей скобки.
String? _extractJson(String content) {
  var s = content.trim();
  if (s.isEmpty) return null;

  // Снять ```json ... ``` или ``` ... ```.
  if (s.startsWith('```')) {
    final firstNl = s.indexOf('\n');
    if (firstNl != -1) s = s.substring(firstNl + 1);
    final fenceEnd = s.lastIndexOf('```');
    if (fenceEnd != -1) s = s.substring(0, fenceEnd);
    s = s.trim();
  }

  final startArr = s.indexOf('[');
  final startObj = s.indexOf('{');
  if (startArr == -1 && startObj == -1) return null;

  final useArr = startArr != -1 && (startObj == -1 || startArr < startObj);
  final start = useArr ? startArr : startObj;
  final end = useArr ? s.lastIndexOf(']') : s.lastIndexOf('}');
  if (end <= start) return null;
  return s.substring(start, end + 1);
}

/// Приводит декодированный JSON к списку записей: поддерживает голый массив и
/// объект-обёртку `{results|markers|анализы: [...]}`.
List<dynamic> _asItemList(Object? decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map) {
    for (final key in const ['results', 'markers', 'items', 'анализы', 'data']) {
      final v = decoded[key];
      if (v is List) return v;
    }
    // Один объект-показатель без обёртки.
    return [decoded];
  }
  return const [];
}

String? _firstString(Map<dynamic, dynamic> m, List<String> keys) {
  final v = _firstValue(m, keys);
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

Object? _firstValue(Map<dynamic, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v != null) return v;
  }
  return null;
}

double? _parseNum(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().replaceAll(',', '.');
  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(s);
  if (match == null) return null;
  return double.tryParse(match.group(0)!);
}

double? _parseConfidence(Object? v) {
  final n = _parseNum(v);
  if (n == null) return null;
  final c = n > 1 ? n / 100 : n; // допускаем проценты
  return c.clamp(0.0, 1.0);
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  final iso = DateTime.tryParse(s);
  if (iso != null) return iso;

  // Формат дд.мм.гггг (или дд/мм/гггг).
  final m = RegExp(r'(\d{1,2})[.\/-](\d{1,2})[.\/-](\d{4})').firstMatch(s);
  if (m != null) {
    final d = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final y = int.parse(m.group(3)!);
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) return DateTime(y, mo, d);
  }
  return null;
}

String _normName(String s) => s
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r'[^a-zа-я0-9]+'), ' ')
    .trim();

String _normUnit(String s) =>
    s.toLowerCase().replaceAll('ё', 'е').replaceAll(RegExp(r'\s+'), '');
