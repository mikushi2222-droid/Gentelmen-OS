enum WeatherCondition {
  sunny,
  cloudy,
  rain,
  snow,
  windy,
  hot,
  cold;

  String get label => switch (this) {
        WeatherCondition.sunny => 'Солнечно',
        WeatherCondition.cloudy => 'Облачно',
        WeatherCondition.rain => 'Дождь',
        WeatherCondition.snow => 'Снег',
        WeatherCondition.windy => 'Ветер',
        WeatherCondition.hot => 'Жара',
        WeatherCondition.cold => 'Холодно',
      };
}
