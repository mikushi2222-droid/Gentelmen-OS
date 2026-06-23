import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gentleman_os/core/ai/router_ai_config.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

/// Ошибка обращения к RouterAI с человекочитаемым сообщением.
class RouterAiException implements Exception {
  RouterAiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'RouterAiException($statusCode): $message';
}

/// Тонкий клиент к RouterAI Chat Completions (OpenAI-совместимый).
/// Все запросы/ответы/ошибки подробно логируются (ключ маскируется).
class RouterAiClient {
  RouterAiClient(this.config, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final RouterAiConfig config;
  final http.Client _http;

  static const String _tag = 'RouterAI';

  /// Текстовый/мультимодальный chat-completion. Возвращает content ответа.
  /// [messages] — массив сообщений в формате OpenAI (role/content).
  /// [provider] — маршрутизация: `{"order": ["deepseek"], "allow_fallbacks": true}`.
  Future<String> chat({
    required List<Map<String, dynamic>> messages,
    String? model,
    bool jsonMode = false,
    double temperature = 0.4,
    bool webSearch = false,
    int webMaxResults = 5,
    Map<String, dynamic>? provider,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    if (!config.isConfigured) {
      log.w(_tag, 'Запрос отклонён: API-ключ не задан');
      throw RouterAiException('API-ключ RouterAI не задан. Настройки → ИИ-советник.');
    }

    final usedModel = model ?? config.model;
    final uri = Uri.parse('${RouterAiConfig.baseUrl}/chat/completions');
    final payload = <String, dynamic>{
      'model': usedModel,
      'messages': messages,
      'temperature': temperature,
      if (jsonMode) 'response_format': {'type': 'json_object'},
      // Веб-поиск RouterAI: грундит ответ в актуальных исследованиях/обзорах.
      if (webSearch)
        'plugins': [
          {'id': 'web', 'max_results': webMaxResults},
        ],
      if (provider != null) 'provider': provider,
    };

    final stopwatch = Stopwatch()..start();
    log.i(_tag,
        'POST /chat/completions model=$usedModel msgs=${messages.length} jsonMode=$jsonMode');
    log.d(_tag, 'Auth key=${_maskKey(config.apiKey!)}');
    log.d(_tag, 'Request body: ${_truncate(jsonEncode(payload), 2000)}');

    http.Response resp;
    try {
      resp = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(payload),
          )
          .timeout(timeout);
    } on Exception catch (err, st) {
      stopwatch.stop();
      log.e(_tag, 'Сетевая ошибка за ${stopwatch.elapsedMilliseconds}мс',
          error: err, stackTrace: st);
      throw RouterAiException('Сеть недоступна: $err');
    }

    stopwatch.stop();
    log.i(_tag,
        'Ответ ${resp.statusCode} за ${stopwatch.elapsedMilliseconds}мс (${resp.bodyBytes.length} байт)');

    if (resp.statusCode != 200) {
      final bodyText = _truncate(utf8.decode(resp.bodyBytes, allowMalformed: true), 1000);
      log.e(_tag, 'Ошибка API ${resp.statusCode}: $bodyText');
      throw RouterAiException(
        _humanError(resp.statusCode, bodyText),
        statusCode: resp.statusCode,
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    } on Exception catch (err, st) {
      log.e(_tag, 'Не удалось распарсить ответ', error: err, stackTrace: st);
      throw RouterAiException('Некорректный ответ сервера');
    }

    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      log.w(_tag, 'Пустой список choices в ответе');
      throw RouterAiException('Модель не вернула ответ');
    }
    final message = (choices.first as Map)['message'] as Map?;
    final content = (message?['content'] as String?)?.trim() ?? '';
    final usage = json['usage'];
    log.d(_tag, 'usage=$usage content.len=${content.length}');
    return content;
  }

  /// Анализ фото вещи через мультимодальную модель.
  /// [imageBase64] — чистый base64 (без префикса), [mime] — image/jpeg и т.п.
  Future<String> analyzeImage({
    required String prompt,
    required String imageBase64,
    String mime = 'image/jpeg',
    String? model,
  }) {
    log.i(_tag, 'Анализ изображения (${imageBase64.length} b64-символов)');
    return chat(
      model: model ?? RouterAiConfig.visionModel,
      messages: [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mime;base64,$imageBase64'},
            },
          ],
        },
      ],
    );
  }

  /// Транскрипция аудио через Whisper (V3.5 Voice UX).
  /// [audioBase64] — чистый base64 аудиофайла, [format] — ogg/mp3/wav/flac/m4a.
  /// [language] — ISO-639-1 код языка (null = авто-определение).
  Future<String> transcribeAudio({
    required String audioBase64,
    String format = 'ogg',
    String? language,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (!config.isConfigured) {
      log.w(_tag, 'Запрос отклонён: API-ключ не задан');
      throw RouterAiException('API-ключ RouterAI не задан. Настройки → ИИ-советник.');
    }

    final uri = Uri.parse('${RouterAiConfig.baseUrl}/audio/transcriptions');
    final payload = <String, dynamic>{
      'model': RouterAiConfig.transcriptionModel,
      'input_audio': {'data': audioBase64, 'format': format},
      if (language != null) 'language': language,
    };

    final stopwatch = Stopwatch()..start();
    log.i(_tag, 'POST /audio/transcriptions format=$format');
    log.d(_tag, 'Auth key=${_maskKey(config.apiKey!)}');

    http.Response resp;
    try {
      resp = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(payload),
          )
          .timeout(timeout);
    } on Exception catch (err, st) {
      stopwatch.stop();
      log.e(_tag, 'Сетевая ошибка транскрипции', error: err, stackTrace: st);
      throw RouterAiException('Сеть недоступна: $err');
    }

    stopwatch.stop();
    log.i(_tag, 'Транскрипция: ${resp.statusCode} за ${stopwatch.elapsedMilliseconds}мс');

    if (resp.statusCode != 200) {
      final bodyText =
          _truncate(utf8.decode(resp.bodyBytes, allowMalformed: true), 1000);
      log.e(_tag, 'Ошибка транскрипции ${resp.statusCode}: $bodyText');
      throw RouterAiException(_humanError(resp.statusCode, bodyText),
          statusCode: resp.statusCode);
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    } on Exception catch (err, st) {
      log.e(_tag, 'Ошибка парсинга ответа транскрипции', error: err, stackTrace: st);
      throw RouterAiException('Некорректный ответ сервера');
    }

    final text = json['text'] as String? ?? '';
    log.d(_tag, 'transcription usage=${json['usage']} text.len=${text.length}');
    return text.trim();
  }

  /// Синтез речи (TTS) через RouterAI (V3.5 Voice UX).
  /// Возвращает сырые байты аудио (mp3 или pcm).
  /// [voice] — идентификатор голоса (зависит от модели).
  Future<List<int>> synthesizeSpeech({
    required String text,
    String? model,
    String voice = 'nova',
    String responseFormat = 'mp3',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!config.isConfigured) {
      log.w(_tag, 'Запрос отклонён: API-ключ не задан');
      throw RouterAiException('API-ключ RouterAI не задан. Настройки → ИИ-советник.');
    }

    final usedModel = model ?? RouterAiConfig.synthesisModel;
    final uri = Uri.parse('${RouterAiConfig.baseUrl}/audio/speech');
    final payload = <String, dynamic>{
      'model': usedModel,
      'input': text,
      'voice': voice,
      'response_format': responseFormat,
    };

    final stopwatch = Stopwatch()..start();
    log.i(_tag,
        'POST /audio/speech model=$usedModel voice=$voice len=${text.length}');
    log.d(_tag, 'Auth key=${_maskKey(config.apiKey!)}');

    http.Response resp;
    try {
      resp = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(payload),
          )
          .timeout(timeout);
    } on Exception catch (err, st) {
      stopwatch.stop();
      log.e(_tag, 'Сетевая ошибка синтеза речи', error: err, stackTrace: st);
      throw RouterAiException('Сеть недоступна: $err');
    }

    stopwatch.stop();
    log.i(_tag,
        'TTS: ${resp.statusCode} за ${stopwatch.elapsedMilliseconds}мс (${resp.bodyBytes.length} байт)');

    if (resp.statusCode != 200) {
      final bodyText =
          _truncate(utf8.decode(resp.bodyBytes, allowMalformed: true), 1000);
      log.e(_tag, 'Ошибка TTS ${resp.statusCode}: $bodyText');
      throw RouterAiException(_humanError(resp.statusCode, bodyText),
          statusCode: resp.statusCode);
    }

    return resp.bodyBytes;
  }

  void close() => _http.close();

  // ── helpers ───────────────────────────────────────────────────────────
  static String _maskKey(String key) =>
      key.length <= 8 ? '***' : '${key.substring(0, 4)}…${key.substring(key.length - 4)}';

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…(+${s.length - max})';

  static String _humanError(int code, String body) => switch (code) {
        401 => 'Неверный API-ключ RouterAI',
        402 => 'Недостаточно средств на балансе RouterAI',
        429 => 'Слишком много запросов, попробуйте позже',
        500 || 502 => 'Ошибка провайдера, попробуйте другую модель',
        503 => 'Нет доступного провайдера для модели',
        _ => 'Ошибка RouterAI ($code)',
      };
}
