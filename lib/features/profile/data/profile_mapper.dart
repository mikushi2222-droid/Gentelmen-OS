import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

extension ProfileRowMapper on UserProfileData {
  UserProfileModel toDomain() => UserProfileModel(
        height: height,
        weight: weight,
        waist: waist,
        chest: chest,
        hips: hips,
        shoulders: shoulders,
        neck: neck,
        shoeSize: shoeSize,
        stylePreferences: List<String>.from(
          (jsonDecode(stylePreferences) as List).cast<String>(),
        ),
        colorPreferences: List<String>.from(
          (jsonDecode(colorPreferences) as List).cast<String>(),
        ),
        budgetTier: budgetTier,
        restrictions: List<String>.from(
          (jsonDecode(restrictions) as List).cast<String>(),
        ),
        updatedAt: updatedAt,
      );
}

UserProfileCompanion profileToCompanion(UserProfileModel p) =>
    UserProfileCompanion(
      id: const Value(0),
      height: Value(p.height),
      weight: Value(p.weight),
      waist: Value(p.waist),
      chest: Value(p.chest),
      hips: Value(p.hips),
      shoulders: Value(p.shoulders),
      neck: Value(p.neck),
      shoeSize: Value(p.shoeSize),
      stylePreferences: Value(jsonEncode(p.stylePreferences)),
      colorPreferences: Value(jsonEncode(p.colorPreferences)),
      budgetTier: Value(p.budgetTier),
      restrictions: Value(jsonEncode(p.restrictions)),
      updatedAt: Value(p.updatedAt),
    );
