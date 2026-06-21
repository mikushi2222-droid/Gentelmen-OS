import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';

part 'outfit.freezed.dart';
part 'outfit.g.dart';

@freezed
class OutfitScore with _$OutfitScore {
  const factory OutfitScore({
    @Default(0) double fitScore,
    @Default(0) double colorScore,
    @Default(0) double occasionScore,
    @Default(0) double weatherScore,
    @Default(0) double comfortScore,
    @Default([]) List<String> explanation,
  }) = _OutfitScore;

  const OutfitScore._();

  double get total =>
      fitScore * 0.30 +
      occasionScore * 0.25 +
      weatherScore * 0.20 +
      colorScore * 0.15 +
      comfortScore * 0.10;

  double get totalScaled => (total * 100).clamp(0, 100);

  factory OutfitScore.fromJson(Map<String, dynamic> json) =>
      _$OutfitScoreFromJson(json);
}

@freezed
class OutfitModel with _$OutfitModel {
  const factory OutfitModel({
    required String id,
    required String name,
    required Occasion occasion,
    WeatherCondition? weather,
    int? temperatureC,
    @Default(DressCode.casual) DressCode dressCode,
    @Default(Season.all) Season season,
    @Default([]) List<String> itemIds,
    @Default(OutfitScore()) OutfitScore score,
    String? notes,
    required DateTime createdAt,
  }) = _OutfitModel;

  factory OutfitModel.fromJson(Map<String, dynamic> json) =>
      _$OutfitModelFromJson(json);
}
