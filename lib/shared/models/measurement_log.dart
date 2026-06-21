import 'package:freezed_annotation/freezed_annotation.dart';

part 'measurement_log.freezed.dart';
part 'measurement_log.g.dart';

@freezed
abstract class MeasurementLog with _$MeasurementLog {
  const factory MeasurementLog({
    required String id,
    required DateTime date,
    double? weight,
    double? waist,
    double? chest,
    double? hips,
    int? steps,
    String? notes,
  }) = _MeasurementLog;

  factory MeasurementLog.fromJson(Map<String, dynamic> json) =>
      _$MeasurementLogFromJson(json);
}
