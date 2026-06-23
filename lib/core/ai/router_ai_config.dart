import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Конфигурация подключения к RouterAI (OpenAI-совместимый API).
/// Документация: https://routerai.ru/docs  ·  спецификация: docs/13-packages-spec.md
class RouterAiConfig {
  const RouterAiConfig({this.apiKey, this.model = defaultModel});

  /// Базовый endpoint (OpenAI-совместимый).
  static const String baseUrl = 'https://routerai.ru/api/v1';

  /// Основная текстовая модель для анализа (по умолчанию). Реальный slug
  /// RouterAI (см. /api/v1/models): Gemini 3.5 Flash — мультимодальная.
  static const String defaultModel = 'google/gemini-3.5-flash';

  /// Мультимодальная модель для считывания анализов со скринов/фото бланков.
  /// Распознавание — только через API (своего оффлайн-движка нет).
  static const String visionModel = 'google/gemini-3.5-flash';

  /// Модель для транскрипции аудио (Voice UX, V3.5).
  static const String transcriptionModel = 'openai/whisper-large-v3';

  /// Модель для синтеза речи (Voice UX, V3.5).
  static const String synthesisModel = 'x-ai/grok-voice-tts-1.0';

  /// Доступные модели для выбора в настройках (только реальные slug RouterAI).
  /// Основная — Gemini 3.5 Flash; Haiku/Sonnet на RouterAI отсутствуют.
  static const List<String> availableModels = [
    'google/gemini-3.5-flash',
    'google/gemini-2.5-flash',
    'google/gemini-2.5-pro',
  ];

  final String? apiKey;
  final String model;

  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  /// Философская база советов по стилю — ориентир для ИИ-промптов.
  /// Bernhard Roetzel («Der Gentleman»), G. Bruce Boyer («True Style»),
  /// Alan Flusser («Dressing the Man»).
  static const String stylePhilosophy =
      'Опирайся на принципы классических авторитетов мужского стиля: '
      'Бернхард Ройцель (Roetzel, «Der Gentleman») — качество, сдержанность, '
      'вневременная классика; Алан Флассер (Flusser, «Dressing the Man») — '
      'посадка, пропорции и гармония цвета с типом внешности; '
      'Дж. Брюс Бойер (Boyer, «True Style») — индивидуальность, фактуры тканей '
      'и непринуждённая элегантность. Цени постоянство стиля над модой, '
      'правильную посадку и качество над количеством.';

  RouterAiConfig copyWith({String? apiKey, String? model}) => RouterAiConfig(
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
      );
}

const String _kApiKey = 'routerai_api_key';
const String _kModel = 'routerai_model';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// Текущая конфигурация RouterAI из защищённого хранилища.
final routerAiConfigProvider = FutureProvider<RouterAiConfig>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final key = await storage.read(key: _kApiKey);
  final model = await storage.read(key: _kModel);
  return RouterAiConfig(
    apiKey: key,
    model: model ?? RouterAiConfig.defaultModel,
  );
});

/// Сохранение/очистка настроек RouterAI.
class RouterAiSettings {
  RouterAiSettings(this._storage, this._ref);

  final FlutterSecureStorage _storage;
  final Ref _ref;

  Future<void> save({String? apiKey, String? model}) async {
    if (apiKey != null) {
      await _storage.write(key: _kApiKey, value: apiKey.trim());
    }
    if (model != null) {
      await _storage.write(key: _kModel, value: model);
    }
    _ref.invalidate(routerAiConfigProvider);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kApiKey);
    await _storage.delete(key: _kModel);
    _ref.invalidate(routerAiConfigProvider);
  }
}

final routerAiSettingsProvider = Provider<RouterAiSettings>(
  (ref) => RouterAiSettings(ref.watch(secureStorageProvider), ref),
);
