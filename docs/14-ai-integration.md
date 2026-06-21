# 14. Интеграция ИИ (RouterAI) и логирование

> Облачный ИИ-слой подключается **поверх** оффлайн-движка и опционален: без
> ключа приложение полностью работает на локальных правилах. С ключом —
> анализ стиля и здоровья выполняет LLM через RouterAI.

## 1. Архитектура

```
                ┌─────────────────────────────┐
                │        AiAdvisor (порт)      │  abstract interface
                └──────────────┬──────────────┘
                 ┌─────────────┴─────────────┐
        LocalAiAdvisor               RouterAiAdvisor
     (оффлайн, правила)        (RouterAI + fallback=Local)
                                       │
                                RouterAiClient ── http ──> RouterAI API
```

- `aiAdvisorProvider` возвращает `RouterAiAdvisor`, если задан ключ,
  иначе `LocalAiAdvisor`. UI ничего не знает о реализации.
- Любая ошибка облака → тихий откат на оффлайн-движок (без падений).

## 2. Файлы

| Файл | Роль |
|------|------|
| `core/ai/ai_advisor.dart` | Порт `AiAdvisor` |
| `core/ai/local_ai_advisor.dart` | Оффлайн-реализация (правила) |
| `core/ai/router_ai_config.dart` | Конфиг + хранение ключа (secure storage) |
| `core/ai/router_ai_client.dart` | OpenAI-совместимый HTTP-клиент + логи |
| `core/ai/router_ai_advisor.dart` | Облачный советник по стилю + fallback |
| `core/ai/ai_advisor_provider.dart` | Провайдеры выбора реализации |
| `features/health/domain/health_ai_analyzer.dart` | Доказательный разбор здоровья |

## 3. Конфигурация и ключ

- Ключ вводится в **Настройки → ИИ-советник → RouterAI**.
- Хранится в `flutter_secure_storage` (Keystore на Android) — не в коде, не в БД.
- Выбор модели: `openai/gpt-4o` (по умолч.), `gpt-4o-mini`,
  `anthropic/claude-sonnet-4.5`, `google/gemini-2.5-flash`, `openai/gpt-oss-120b`.

```dart
final cfg = await ref.watch(routerAiConfigProvider.future); // RouterAiConfig
final client = ref.watch(routerAiClientProvider);           // null, если нет ключа
final aiEnabled = ref.watch(aiCloudEnabledProvider);        // bool
```

## 4. Клиент

```dart
final answer = await client.chat(
  messages: [
    {'role': 'system', 'content': '...'},
    {'role': 'user', 'content': '...'},
  ],
  jsonMode: true,        // response_format: json_object
  webSearch: true,       // plugins: [{id: web}] — грундинг в исследованиях
  temperature: 0.4,
);

// Мультимодальный анализ фото вещи:
final verdict = await client.analyzeImage(
  prompt: 'Оцени посадку и сочетаемость',
  imageBase64: base64Photo,         // без префикса data:
  mime: 'image/jpeg',
);
```

Ошибки нормализуются в `RouterAiException` с человекочитаемым сообщением
(401 — неверный ключ, 402 — нет средств, 429 — лимит, 503 — нет провайдера).

## 4a. Философская база советов по стилю

ИИ-промпты по моде грундятся в `RouterAiConfig.stylePhilosophy` — принципах
классиков мужского стиля: **Бернхард Ройцель** (Roetzel, «Der Gentleman»),
**Алан Флассер** (Flusser, «Dressing the Man»), **Дж. Брюс Бойер** (Boyer,
«True Style»): вневременность над модой, посадка и пропорции, гармония цвета,
качество над количеством.

## 5. Анализ показателей здоровья

`HealthAiAnalyzer` строит промпт из последних маркеров (значение, референс,
статус) и через RouterAI с **веб-поиском** выдаёт доказательный разбор:
интерпретация, коррекция дефицитов (питание, добавки с дозировками, образ
жизни), ориентиры по контролю и что согласовать с врачом.

```dart
final async = ref.watch(healthAiAnalysisProvider); // AsyncValue<String>
// перезапуск: ref.invalidate(healthAiAnalysisProvider)
```

UI: экран «Мужское здоровье» → кнопка ✨ (ИИ-анализ) открывает лист с разбором.

> ⚠️ Это образовательная информация на основе опубликованных исследований и
> практики, **не замена консультации врача** (особенно дозировки и рецептурные
> препараты). Дисклеймер выводится в UI.

## 6. Безопасность и приватность

- Данные не покидают устройство **без явного действия** пользователя
  (ввод ключа и запуск анализа — осознанный шаг).
- В запросах к RouterAI можно ограничить гео-обработку: `provider.country: "ru"`.
- API-ключ маскируется в логах (`abcd…wxyz`).

## 7. Логирование (`core/utils/app_logger.dart`)

Назначение — отладка и разбор инцидентов (особенно сетевых запросов к ИИ).

- Уровни: `debug / info / warning / error`. В release `debug` отключён.
- Печать через `dart:developer.log` (видно в DevTools/`logcat`).
- Кольцевой буфер последних 500 записей в памяти.
- Экран **Настройки → Журнал отладки**: фильтр по уровню, копирование, очистка.

```dart
log.i('RouterAI', 'POST /chat/completions model=openai/gpt-4o');
log.e('RouterAI', 'Ошибка API 401', error: e);
```

Что логируется в ИИ-слое: модель, число сообщений, размер/код/время ответа,
usage-токены, обрезанные тело запроса и ошибки. Ключ — только маскированный.

## 8. Анализ фото вещей (vision)

Карточка вещи (`/wardrobe/:id`) при наличии фото показывает кнопку
**«ИИ-анализ фото»**: фото кодируется в base64 и отправляется в мультимодальную
модель (`google/gemini-2.5-flash`) через `clothingPhotoAnalysisProvider`.
Модель оценивает фасон, посадку, ткань, сочетаемость и даёт советы.

```dart
final async = ref.watch(clothingPhotoAnalysisProvider(item)); // AsyncValue<String>
```

## 9. Дальнейшее развитие

- Кэширование ИИ-ответов, чтобы не платить за повторные запросы.
- Стриминг ответов (SSE) для длинных разборов.
