# Changelog — Gentleman OS

All notable changes are documented here in reverse chronological order.

---

## [Unreleased] — V3.x Planning

### Added
- `RouterAiClient.transcribeAudio()` — Whisper STT endpoint (`/audio/transcriptions`),
  foundation for V3.5 Voice UX
- `RouterAiClient.synthesizeSpeech()` — TTS endpoint (`/audio/speech`),
  foundation for V3.5 Voice UX
- `RouterAiClient.chat()` — `provider` parameter for explicit provider routing
  (order, only, ignore, allow_fallbacks, country)
- `RouterAiConfig.transcriptionModel` / `synthesisModel` constants
- `RouterAiConfig.availableModels` — added `gemini-2.5-pro`, `deepseek-r1`
- `_humanError` — handles 500/502 (provider error) in addition to existing codes
- `docs/14-ai-integration.md` — audio API, provider routing, model constants table

### Added (previous)
- `docs/16-weight-health-ai-spec.md` — full V3.x feature specification:
  safe weight loss rate system, Compliance Score, AI food analysis (text/photo/voice),
  behavioral intelligence engine (drift, relapse, plateau), recovery layer,
  biohacking layer, operator-style UX rules, identity engine
- `docs/07-roadmap.md` — V3.0–V3.6 development phases added with detailed task lists
- `CLAUDE.md` — project memory with product niche, V3.x module status, critical design rules

### Fixed
- Duplicate `import services_provider.dart` in `dashboard_screen.dart`

---

## [V2.12] — 2026-06-22 — Quality: tests & analyze

### Added
- Widget test: `PurchasesScreen` — 5 tabs, status filtering, empty states
  (`test/widget/purchases/purchases_screen_test.dart`)
- Widget test: `OutfitDetailScreen` — score breakdown, explanations, not-found state
  (`test/widget/outfit/outfit_detail_screen_test.dart`)
- Unit test: `LocalAiAdvisor` — offline recommendations
  (`test/unit/ai/local_ai_advisor_test.dart`)
- DB test: schema v7 — onCreate + seed verification
  (`test/unit/db/migration_test.dart`)

### Fixed
- `XpType.habits` was missing from XpType enum, causing build failures in RPG module
- Resolved `custom_lint` / `riverpod_lint` version conflict (`3243bcf`)

---

## [V2.11] — 2026-06-18 — Quality: expanded tests

### Added
- Unit tests: `computeWearForecast` — all 5 urgency branches
- Unit tests: `generateDailyMissions` — flag combinations
- Unit tests: `computeGentlemanScore` — 5-component formula
- Unit tests: `scoreOutfit` — fit/color/occasion/weather/comfort axes
- Unit tests: `markerStatus` — health: normal/warning/risk
- Widget smoke tests: `DashboardScreen`, `WardrobeScreen`

---

## [V2.10] — 2026-06-16 — Depth: wardrobe filters, quick habits, style context

### Added
- Wardrobe: multi-filter BottomSheet (season + color + brand chips)
- Dashboard: quick habit completion checkboxes without navigation
- Style advisor: top-5 urgency items + season passed to AI prompt
- Health: "overdue analysis" reminder tile per marker interval

---

## [V2.9] — 2026-06-14 — UX closures

### Added
- Dashboard: habits mini-block (N/total + streak + tap → habits screen)
- Outfit Builder: occasion filter chips on outfits list screen
- Outfit rating screen (`/outfits/:id/rate`) — 1–5 stars + note
- Purchase → wardrobe: AlertDialog on status change to `bought`

---

## [V2.8] — 2026-06-12 — Outfit depth

### Added
- Outfit score breakdown saved to DB as JSON (`scoreBreakdown` column)
- Outfit detail: 5-axis breakdown display with LinearProgressIndicator
- "Wear full outfit" batch action (increments wearCount for all items)
- Wardrobe search: text search across name, brand, color, notes

---

## [V2.7] — 2026-06-10 — Dashboard + Knowledge

### Added
- Dashboard: urgency strip "Wear today" (horizontal scroll, WearUrgency-based)
- Knowledge: bookmarks/favorites filter tab
- Knowledge: article read time estimate (words / 200 wpm)

---

## [V2.6] — 2026-06-08 — Urgency + missions + purchases

### Added
- Wardrobe: urgency-based sort (overdue → stale → fresh)
- Daily missions: `outfit-today` mission type
- Purchases: 5 status tabs (All / Wish / Planned / Bought / Rejected)

---

## [V2.5] — 2026-06-06 — Fitness deltas + habit calendar

### Added
- Fitness: trend delta arrows (↑↓) on measurement cards
- Habits: 7-day calendar strip with completion dots and streak

---

## [V2.4] — 2026-06-04 — WearForecast

### Added
- `WearForecast` / `WearUrgency` — wear prediction on clothing item detail
- 5 urgency states: overdue / stale / scheduled / fresh / neverWorn

### Fixed
- 6 code-review bugs: wear transaction, `insertOrIgnore` seed, `hasRecentMarker`,
  `ref.invalidate`, test clock, mission daily cap

---

## [V2.3] — 2026-06-02 — AI wardrobe advisor

### Added
- `styleAdviceProvider` — AI style recommendations for wardrobe items
- Clothing item photo AI analysis (vision via `RouterAiClient`)

---

## [V2.2] — 2026-05-30 — Men's Health module

### Added
- `HealthMarkers` table (migration v4→v5→v6), 16 marker types
- `HealthScreen` with color-coded status cards (normal/warning/risk)
- `HealthMarkerDetailScreen` with fl_chart dynamic chart
- AI analysis via RouterAI with web search grounding
- Health index [0–100] from marker statuses
- XP for logging health markers (`XpType.health`)

---

## [V2.1] — 2026-05-28 — Anime mascot

### Added
- `MascotAvatar` widget with 4 moods: sleeping / neutral / pleased / proud
- Reacts to Gentleman Score thresholds (< 20 / < 50 / < 80 / ≥ 80)

---

## [V2.0] — 2026-05-25 — Foundation complete (M1–M10)

### Completed milestones
- M1: Scaffold, Material 3 dark theme, 5-tab navigation
- M2: Drift DB v1 + DAOs + seed + migrations
- M3: Profile + measurements + BMI + body type recommendations
- M4: Wardrobe CRUD + photo + cost-per-wear
- M5: Outfit Builder — scoring 5 axes (fit/color/occasion/weather/comfort)
- M6: Knowledge base — Markdown, search, bookmarks, read-time
- M7: Fitness — measurements log + fl_chart charts
- M8: RPG — XP × 8 types, Gentleman Score (5 components), achievements, daily missions
- M9: Purchases — 48h rule, priorities, status management
- M10: Export/clear, settings, debug log

### Added
- `AiAdvisor` port with `LocalAiAdvisor` (offline) + `RouterAiAdvisor` (cloud)
- RouterAI integration — OpenAI-compatible API, secure key storage
- GitHub Actions CI/CD — analyze + test + build APK + release workflow
