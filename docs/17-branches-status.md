# 17. Статус веток

> Снимок на **2026-06-24**. Текущая ветка сброшена на `origin/main` (reset --hard).

---

## Сводка

| Ветка | HEAD | Впереди main | Позади main | Состояние |
|-------|------|:---:|:---:|-----------|
| **`main`** | `9668c6b` | — | — | 🟢 эталон (V2.12 + analyze clean) |
| **`claude/code-docs-review-x4vztn`** | `9668c6b` | **0** | 0 | 🟢 **текущая рабочая** (= main) |

---

## Актуальная рабочая ветка

**`claude/code-docs-review-x4vztn`** — ветка разработки. Сброшена на `origin/main`
после того, как предыдущий PR #2 доставил все наработки.

```
9668c6b fix(analyze): clear the two fatal warnings (only infos remain)
e1ca8db fix: repair build/analyze breakage inherited from main (CI was red)
8ae04bb fix(ux): confirm destructive deletes for outfits and health markers
c5a5fc7 fix(ai): реальные slug моделей RouterAI (Gemini 3.5 Flash)
a14df71 feat(health): авто-импорт анализов с фото + модели Gemini 3 Flash / Haiku 5
18bd8e8 feat(health): расшифровка фото бланка анализов через Router AI (V2.7 ядро)
737d52f feat(logging): журналировать все мутации данных + правило main в CLAUDE.md
...
```

### Что в main относительно исходного состояния (V2.7 → сейчас)

| Область | Статус |
|---------|--------|
| V2.4–V2.12 фичи | ✅ все реализованы |
| Schema v7 (`discipline-habits` fix) | ✅ |
| Импорт анализов с фото (`LabPhotoAnalyzer`) | ✅ |
| Confirm destructive deletes (outfits + markers) | ✅ |
| RouterAI model slugs (Gemini 3.5 Flash) | ✅ |
| `docs/16-weight-health-ai-spec.md` | ✅ V3.x спецификация |
| RouterAI audio (`transcribeAudio`, `synthesizeSpeech`) | ✅ |
| RouterAI provider routing | ✅ |
| CI fix (`custom_lint`/`riverpod_lint` удалены) | ✅ |
| `withOpacity` → `withValues(alpha:)` в 16 файлах | ✅ |
| `XpType.habits` bug fix | ✅ |
| Widget-тесты, migration-тест v7 | ✅ |
| `flutter analyze --no-fatal-infos` — 0/0/infos | ✅ |

---

## main (эталон)

Последний коммит — `9668c6b` (fix(analyze): clear the two fatal warnings).
Содержит V2.1–V2.12 + фичи здоровья (lab photo import, biological age).

---

## Рекомендуемые действия

1. **Начать V3.0** — новая ветка `feature/v3-weight-loss` от `main`
2. Реализовать V3.0 A/B/C/D (Safe Weight Loss Rate, Compliance Score, Advanced Metrics, DB migration v7 → v8)
3. PR → merge to `main`
