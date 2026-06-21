import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    @Default(0) double height,
    @Default(0) double weight,
    @Default(0) double waist,
    @Default(0) double chest,
    @Default(0) double hips,
    @Default(0) double shoulders,
    @Default(0) double neck,
    @Default(0) double shoeSize,
    @Default([]) List<String> stylePreferences,
    @Default([]) List<String> colorPreferences,
    @Default(1) int budgetTier,
    @Default([]) List<String> restrictions,
    required DateTime updatedAt,
  }) = _UserProfileModel;

  const UserProfileModel._();

  bool get isLargeFrame => waist >= 100 || weight >= 100;

  bool get isFilled => height > 0 && weight > 0;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}
