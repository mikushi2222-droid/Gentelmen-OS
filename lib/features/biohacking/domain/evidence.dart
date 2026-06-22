/// Рейтинг доказательности добавки/протокола. База знаний, не реклама.
/// См. docs/16-vision-three-levels-and-biohacking.md.
library;

/// Уровень доказательности эффекта.
enum EvidenceRating {
  /// Много качественных исследований.
  a,

  /// Есть данные, но база ограничена.
  b,

  /// Слабая доказательная база.
  c;

  /// Короткая метка («A», «B», «C»).
  String get code => switch (this) {
        EvidenceRating.a => 'A',
        EvidenceRating.b => 'B',
        EvidenceRating.c => 'C',
      };

  /// Человекочитаемое описание уровня.
  String get label => switch (this) {
        EvidenceRating.a => 'A — много исследований',
        EvidenceRating.b => 'B — есть данные',
        EvidenceRating.c => 'C — слабая база',
      };

  /// Парсинг из строкового кода БД/сида ('A'/'B'/'C', регистр не важен).
  /// Неизвестное значение трактуем как слабую базу (C) — консервативно.
  static EvidenceRating fromCode(String code) => switch (code.toUpperCase()) {
        'A' => EvidenceRating.a,
        'B' => EvidenceRating.b,
        _ => EvidenceRating.c,
      };
}
