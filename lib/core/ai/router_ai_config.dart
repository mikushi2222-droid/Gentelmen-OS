import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Конфигурация подключения к RouterAI (OpenAI-совместимый API).
/// Документация: https://routerai.ru/docs  ·  спецификация: docs/13-packages-spec.md
class RouterAiConfig {
  const RouterAiConfig({this.apiKey, this.model = defaultModel});

  /// Базовый endpoint (OpenAI-совместимый).
  static const String baseUrl = 'https://routerai.ru/api/v1';

  /// Текстовая модель по умолчанию.
  static const String defaultModel = 'openai/gpt-4o';

  /// Мультимодальная модель для анализа фото вещей.
  static const String visionModel = 'google/gemini-2.5-flash';

  /// Доступные модели для выбора в настройках.
  static const List<String> availableModels = [
    'openai/gpt-4o',
    'openai/gpt-4o-mini',
    'anthropic/claude-sonnet-4.5',
    'google/gemini-2.5-flash',
    'openai/gpt-oss-120b',
  ];

  final String? apiKey;
  final String model;

  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

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
