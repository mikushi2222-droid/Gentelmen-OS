# 17. Статус веток

> Снимок на **2026-06-24**. Ребейз на актуальный `origin/main` выполнен в сессии
> 2026-06-24; план консолидации из `18-branch-consolidation-plan.md` реализован.

---

## Сводка

| Ветка | HEAD | Впереди main | Позади main | Состояние |
|-------|------|:---:|:---:|-----------|
| **`main`** | `cd68d39` | — | — | 🟢 эталон (до V2.7) |
| **`claude/claude-md-project-memory-2ouxu6`** | `febe0f0` | **24** | 0 | 🟢 **актуальная рабочая** |
| `claude/gentleman-os-plan-cgm6hh` | `ff32c59` | ~22 | ~7 | ⚪ суперсет — всё уже в рабочей ветке |

---

## Актуальная рабочая ветка

**`claude/claude-md-project-memory-2ouxu6`** — единственная ветка для разработки.
Содержит весь `main` (0 коммитов позади) плюс 24 своих:

```
febe0f0 feat(ai): audio STT/TTS + provider routing
e7c0f0c fix(db): restore schema v7 migration (lost in rebase)
d46398d fix+docs: Phase 4 quality — CI fix, widget tests, production plan
7fd84e0 docs: V3.x weight loss + AI nutrition spec (docs/16-weight-health-ai-spec.md)
b760578 fix+test: XpType.habits bug + widget & migration tests
3b235f7 fix(db): discipline-habits category + migration v7
45d0840 docs: full doc sync against code (schema v6)
a04afbb docs: remove custom_lint/riverpod_lint (pub conflict)
b0cde2b test: V2.11 — unit + widget smoke tests
be4ff83 feat: V2.10 — multi-filter wardrobe, quick habit, style advisor
1a1ca21 feat: V2.9 — habits dashboard block, occasion filter, purchase→wardrobe
88fb71a docs: roadmap + production plan actualized to V2.8
9ad33cb feat: V2.8 — score breakdown, batch wear, wardrobe search
3fd0f07 feat: V2.7 — urgency strip, knowledge filters, read time
dc4d559 feat: V2.6 — urgency sort, outfit-today fix, 5 tabs purchases
7f1d737 feat: V2.5 — fitness trend deltas + 7-day habit calendar
3e3e645 fix: 6 code-review bugs
842eff8 fix: articlesReadLast7d from DB instead of hardcoded 0
47baa80 feat: health marker mission in daily missions
cc6760e feat: health XP in Gentleman Score (5-component formula)
884b0ef fix: incrementWearCount → WearLogs row (lastWornAt)
ae35638 test: ScoreRing + ClothingCard wear forecast widget tests
1b34ec9 fix: withOpacity → withValues(alpha:) + health habits v6
ee136e2 feat(v2.4+v2.2): garmentWearForecast + health module (крупная)
```

### Что в ветке (относительно `main`)

| Область | Статус |
|---------|--------|
| V2.4–V2.12 фичи | ✅ все реализованы |
| Schema v7 (`discipline-habits` fix) | ✅ |
| `docs/16-weight-health-ai-spec.md` | ✅ V3.x спецификация |
| RouterAI audio (`transcribeAudio`, `synthesizeSpeech`) | ✅ |
| RouterAI provider routing | ✅ |
| CI fix (`custom_lint`/`riverpod_lint` удалены) | ✅ |
| `XpType.habits` bug fix | ✅ |
| Widget-тесты, migration-тест v7 | ✅ |

---

## main (эталон)

Релизная линия. Последний коммит — `cd68d39` (feat knowledge: время чтения статьи).
Содержит V2.1–V2.7 + закалка CI.

---

## Обсолетные ветки

### `claude/gentleman-os-plan-cgm6hh`

Исторически — источник фич V2.5–V2.12, которые в этой сессии были перенесены
в `claude/claude-md-project-memory-2ouxu6` через ребейз на `origin/main`.
Всё уникальное содержимое теперь есть в рабочей ветке; ветка может быть удалена.

---

## Рекомендуемые действия

1. **PR ветки в `main`** (`claude/claude-md-project-memory-2ouxu6` → `main`)
   — доставит V2.8–V2.12, schema v7, V3.x docs, RouterAI audio.
2. **Удалить** `claude/gentleman-os-plan-cgm6hh` после мёржа (или сразу —
   всё содержимое уже в рабочей ветке).
3. После мёржа — старт V3.0 (новая короткая feature-ветка → PR → `main`).
