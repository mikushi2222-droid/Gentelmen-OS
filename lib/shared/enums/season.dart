enum Season {
  spring,
  summer,
  autumn,
  winter,
  all;

  String get label => switch (this) {
        Season.spring => 'Весна',
        Season.summer => 'Лето',
        Season.autumn => 'Осень',
        Season.winter => 'Зима',
        Season.all => 'Всесезонный',
      };
}
