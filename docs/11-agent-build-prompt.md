# 11. Промпт для кодирующего агента

Готовый промпт, который можно вставить в Claude Code, Cursor Agent, Gemini CLI
или другой кодирующий агент для пошаговой реализации по этому плану.

```text
You are a principal Flutter engineer and product architect.

Build a personal offline-first Android app called "Gentleman OS" for a single user only.

Product goal:
Create a private decision-support app for a modern gentleman. The app helps with
style, clothing, grooming, etiquette, fitness tracking, reading, habit building,
and personal progress.

Hard constraints:
- Android only
- Flutter app
- Must work fully offline
- No backend
- No authentication
- No social features
- No multi-user support
- No cloud sync in v1
- Privacy-first
- Maintainable codebase
- Production quality

Use these technologies:
- Flutter
- Dart
- Material 3 UI
- Riverpod for state management and dependency injection
- go_router for navigation
- Drift + SQLite for local persistence
- freezed for immutable models
- json_serializable for JSON serialization
- flutter_secure_storage only for sensitive secrets if needed
- build_runner for code generation

Architectural rules:
- Feature-first structure
- Layered architecture with presentation, application/logic, domain, and data layers
- UI must not access database directly
- All state changes go through use cases/repositories
- Repositories are the single source of truth
- All data must persist locally
- Support export/import of all user data
- Keep business rules isolated from Flutter widgets
- Prefer immutable models and pure functions
- Use typed routes if practical
- Write tests for business logic and critical UI

Core features:
1. Dashboard — daily summary, gentleman score, today's missions, quick access.
2. Personal Profile — measurements, style/color/budget preferences, derived recommendations.
3. Digital Wardrobe — items with photo, categories, attributes, search/filter/sort, cost-per-wear.
4. Outfit Builder — inputs (occasion, weather, temperature, season, dress code, mood), 1–3 suggestions, save, rate.
5. Knowledge Base — local Markdown articles, categories, search, favorites, bookmarks, tags.
6. Fitness and Measurements — weight/waist/chest logs, progress charts, notes.
7. Gentleman RPG — XP, levels, skills (style, fitness, etiquette, reading, career, finance), achievements, streaks.
8. Purchase Advisor — desired items, priorities, budget, what to buy next.

Business rules:
- Avoid skinny fits for large body types
- Prefer medium/high rise trousers for large waistlines
- Recommend structured, moderate-width lapels
- Prefer stable, heavier fabrics over thin shiny fabrics
- Prioritize proportionality, comfort, and repeatability
- Outfit scoring must use fit, color harmony, occasion match, weather match, and comfort
- Recommendations should be explainable

Data requirements:
Define entities, DTOs, DAOs, repositories, and local tables for:
UserProfile, ClothingItem, Outfit, MeasurementLog, KnowledgeArticle, Habit,
XpEvent, Achievement, PurchaseWish.

Non-functional requirements:
- Fast startup, smooth scrolling, offline operation
- Reliable local persistence, database migrations
- Accessible UI, dark theme support
- Export/import, crash-safe writes
- Good test coverage

Testing requirements:
- Unit tests for use cases, repositories, scoring rules
- Widget tests for core screens
- Golden tests for dashboard, wardrobe, outfit builder if feasible
- Tests for export/import and database migrations

Deliverables:
1. A complete PRD
2. A technical architecture document
3. Folder structure
4. Data model design
5. Navigation map
6. UI component list
7. Implementation roadmap
8. Test plan
9. Initial codebase scaffold
10. Sample data and seed content
11. Clear README with setup and run instructions

Implementation order:
1. Project scaffold
2. Theme and design system
3. Local database and entities
4. Profile feature
5. Wardrobe feature
6. Outfit builder
7. Knowledge base
8. Fitness tracking
9. RPG system
10. Export/import
11. Tests
12. Polish and refactor

Coding style:
- Clean, readable, idiomatic Dart
- Avoid overengineering
- Prefer small pure functions
- Comment only where needed
- Use meaningful names
- Follow Flutter best practices

Before writing code:
- Propose the full architecture
- List assumptions
- Identify tradeoffs
- Define the data model
- Define the navigation tree
- Define the screen list
- Define the first sprint backlog

When coding:
- Build the app incrementally
- Stop after each milestone and summarize what was completed
- Never break existing functionality
- Keep the app fully runnable at every stage
```

## Как использовать

1. Открой кодирующего агента в корне репозитория.
2. Вставь промпт выше.
3. Попроси сверяться с документами в `docs/` (этот план — источник истины).
4. Веди разработку по [07-roadmap.md](07-roadmap.md), milestone за milestone,
   держа приложение запускаемым на каждом шаге.
