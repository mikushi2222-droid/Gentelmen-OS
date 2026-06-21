enum Fit {
  slim,
  regular,
  relaxed,
  comfort,
  straight;

  String get label => switch (this) {
        Fit.slim => 'Slim',
        Fit.regular => 'Regular',
        Fit.relaxed => 'Relaxed',
        Fit.comfort => 'Comfort',
        Fit.straight => 'Straight',
      };
}
