/// База знаний раздела «Биохакинг»: протоколы и добавки. Не магазин и не
/// реклама — справочник с доказательностью, дозировками и рисками.
/// ВАЖНО: образовательный материал, НЕ медицинские назначения.
/// См. docs/16-vision-three-levels-and-biohacking.md.
library;

import 'package:gentleman_os/features/biohacking/domain/evidence.dart';

/// Готовый протокол-сценарий (сон, энергия, фокус).
class Protocol {
  const Protocol({required this.name, required this.goal, required this.steps});

  final String name;
  final String goal;
  final List<String> steps;
}

/// Карточка добавки в базе знаний.
class Supplement {
  const Supplement({
    required this.name,
    required this.evidence,
    required this.dose,
    required this.risks,
    required this.interactions,
  });

  final String name;
  final EvidenceRating evidence;
  final String dose;
  final String risks;
  final String interactions;
}

/// Протоколы (сид, доступны офлайн).
const kProtocols = <Protocol>[
  Protocol(
    name: 'Сон',
    goal: 'Глубокое восстановление',
    steps: [
      'Магний вечером',
      'Без кофеина после 14:00',
      'Темнота и прохлада в спальне',
      'Отбой в 22:30',
    ],
  ),
  Protocol(
    name: 'Энергия',
    goal: 'Стабильный тонус днём',
    steps: [
      'Качественный сон',
      'Утренний дневной свет 10–15 мин',
      'Ходьба 8–10 тыс. шагов',
      'Белок в каждый приём пищи',
    ],
  ),
  Protocol(
    name: 'Фокус',
    goal: 'Глубокая работа без рассеивания',
    steps: [
      'Блоки глубокой работы 60–90 мин',
      'Уведомления выключены',
      'Омега-3 в рационе',
      'Контроль сахара (без скачков)',
    ],
  ),
];

/// Добавки (сид). Доказательность по шкале A/B/C.
const kSupplements = <Supplement>[
  Supplement(
    name: 'Магний (глицинат)',
    evidence: EvidenceRating.a,
    dose: '200–400 мг вечером',
    risks: 'В больших дозах — послабляющий эффект',
    interactions: 'Может усиливать седативные средства',
  ),
  Supplement(
    name: 'Омега-3 (EPA/DHA)',
    evidence: EvidenceRating.a,
    dose: '1–2 г/сут с едой',
    risks: 'Разжижает кровь',
    interactions: 'Осторожно с антикоагулянтами',
  ),
  Supplement(
    name: 'Витамин D3',
    evidence: EvidenceRating.a,
    dose: '1000–2000 МЕ/сут',
    risks: 'Передозировка при длительном приёме >4000 МЕ',
    interactions: 'Лучше с жирами и витамином K2',
  ),
  Supplement(
    name: 'Креатин моногидрат',
    evidence: EvidenceRating.a,
    dose: '3–5 г/сут',
    risks: 'Возможна небольшая задержка воды',
    interactions: 'Значимых нет',
  ),
  Supplement(
    name: 'Цинк',
    evidence: EvidenceRating.b,
    dose: '10–25 мг/сут',
    risks: 'Натощак — тошнота; конкурирует с медью',
    interactions: 'Не принимать одновременно с кальцием',
  ),
  Supplement(
    name: 'Ашваганда',
    evidence: EvidenceRating.b,
    dose: '300–600 мг экстракта',
    risks: 'Осторожно при болезнях щитовидной железы',
    interactions: 'Усиливает седативные средства',
  ),
];
