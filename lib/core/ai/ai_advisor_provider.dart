import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/ai_advisor.dart';
import 'package:gentleman_os/core/ai/local_ai_advisor.dart';
import 'package:gentleman_os/core/ai/router_ai_advisor.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/ai/router_ai_config.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/knowledge/application/knowledge_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

/// HTTP-клиент RouterAI — есть только если задан API-ключ.
final routerAiClientProvider = Provider<RouterAiClient?>((ref) {
  final cfg = ref.watch(routerAiConfigProvider).value;
  if (cfg == null || !cfg.isConfigured) return null;
  final client = RouterAiClient(cfg);
  ref.onDispose(client.close);
  log.i('AI', 'RouterAI клиент активен (model=${cfg.model})');
  return client;
});

/// Признак того, что облачный ИИ подключён.
final aiCloudEnabledProvider = Provider<bool>(
  (ref) => ref.watch(routerAiClientProvider) != null,
);

/// Текущий советник: RouterAI при наличии ключа, иначе оффлайн-движок.
final aiAdvisorProvider = Provider<AiAdvisor>((ref) {
  const local = LocalAiAdvisor();
  final client = ref.watch(routerAiClientProvider);
  if (client == null) return local;
  return RouterAiAdvisor(client: client, fallback: local);
});

/// Computes style advice from the current wardrobe.
final styleAdviceProvider = FutureProvider<StyleAdvice>((ref) async {
  final wardrobe = await ref.watch(wardrobeListProvider.future);
  final advisor = ref.watch(aiAdvisorProvider);
  return advisor.getStyleAdvice(wardrobe: wardrobe);
});

/// Returns AI-recommended articles based on wardrobe gaps.
final recommendedArticlesProvider =
    FutureProvider<List<KnowledgeArticle>>((ref) async {
  final articles = await ref.watch(knowledgeListProvider.future);
  final wardrobe = await ref.watch(wardrobeListProvider.future);
  final advisor = ref.watch(aiAdvisorProvider);
  return advisor.recommendArticles(
    articles: articles,
    wardrobe: wardrobe,
    limit: 3,
  );
});
