import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/ai_advisor.dart';
import 'package:gentleman_os/core/ai/local_ai_advisor.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';

final aiAdvisorProvider = Provider<AiAdvisor>((ref) {
  return const LocalAiAdvisor();
});

/// Computes style advice from the current wardrobe.
final styleAdviceProvider = FutureProvider<StyleAdvice>((ref) async {
  final wardrobe = await ref.watch(wardrobeListProvider.future);
  final advisor = ref.watch(aiAdvisorProvider);
  return advisor.getStyleAdvice(wardrobe: wardrobe);
});
