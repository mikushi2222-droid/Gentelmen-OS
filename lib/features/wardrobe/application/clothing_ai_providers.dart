import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

/// ИИ-анализ фото вещи через мультимодальную модель RouterAI.
/// On-demand: перезапуск через ref.invalidate(...).
final clothingPhotoAnalysisProvider =
    FutureProvider.autoDispose.family<String, ClothingItem>((ref, item) async {
  final client = ref.watch(routerAiClientProvider);
  if (client == null) {
    throw RouterAiException(
      'ИИ-советник не подключён. Настройки → ИИ-советник → RouterAI.',
    );
  }
  final path = item.imagePath;
  if (path == null || path.isEmpty) {
    throw RouterAiException('У вещи нет фото для анализа.');
  }
  final file = File(path);
  if (!await file.exists()) {
    throw RouterAiException('Файл фото не найден на устройстве.');
  }

  final bytes = await file.readAsBytes();
  final b64 = base64Encode(bytes);
  final mime = path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

  log.i('ClothingAI', 'Анализ фото вещи "${item.name}" (${bytes.length} байт)');

  final prompt = '''
Ты — мужской стилист. Проанализируй вещь на фото: ${item.category.label}${item.color != null ? ', заявленный цвет ${item.color}' : ''}${item.material != null ? ', материал ${item.material}' : ''}.
Оцени по фото: фасон и посадку, качество/фактуру ткани, цвет, универсальность.
Подскажи: с чем сочетать, для каких поводов подходит, чего избегать.
Дай 3–5 кратких практичных совета на русском.''';

  return client.analyzeImage(prompt: prompt, imageBase64: b64, mime: mime);
});
