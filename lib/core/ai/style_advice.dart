/// Represents a style recommendation from an AI advisor.
class StyleAdvice {
  const StyleAdvice({
    required this.summary,
    required this.suggestions,
    this.warnings = const [],
    this.score,
    this.outfitOfDay,
  });

  final String summary;
  final List<String> suggestions;
  final List<String> warnings;
  final double? score;

  /// Concrete "outfit of the day" recommendation (optional, cloud AI only).
  final String? outfitOfDay;
}
