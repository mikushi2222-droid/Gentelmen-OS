/// Represents a style recommendation from an AI advisor.
class StyleAdvice {
  const StyleAdvice({
    required this.summary,
    required this.suggestions,
    this.warnings = const [],
    this.score,
  });

  /// Short human-readable advice (1-2 sentences).
  final String summary;

  /// Specific actionable suggestions.
  final List<String> suggestions;

  /// Items or combinations to avoid.
  final List<String> warnings;

  /// Optional confidence/quality score 0–100.
  final double? score;
}
