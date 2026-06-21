import 'dart:convert';
import 'dart:io';

import 'package:gentleman_os/core/db/daos/habits_dao.dart';
import 'package:gentleman_os/core/db/daos/health_dao.dart';
import 'package:gentleman_os/core/db/daos/knowledge_dao.dart';
import 'package:gentleman_os/core/db/daos/measurement_dao.dart';
import 'package:gentleman_os/core/db/daos/outfit_dao.dart';
import 'package:gentleman_os/core/db/daos/profile_dao.dart';
import 'package:gentleman_os/core/db/daos/purchases_dao.dart';
import 'package:gentleman_os/core/db/daos/rpg_dao.dart';
import 'package:gentleman_os/core/db/daos/wardrobe_dao.dart';

class ExportService {
  const ExportService({
    required this.profileDao,
    required this.wardrobeDao,
    required this.outfitDao,
    required this.measurementDao,
    required this.knowledgeDao,
    required this.habitsDao,
    required this.rpgDao,
    required this.purchasesDao,
    required this.healthDao,
  });

  final ProfileDao profileDao;
  final WardrobeDao wardrobeDao;
  final OutfitDao outfitDao;
  final MeasurementDao measurementDao;
  final KnowledgeDao knowledgeDao;
  final HabitsDao habitsDao;
  final RpgDao rpgDao;
  final PurchasesDao purchasesDao;
  final HealthDao healthDao;

  Future<Map<String, dynamic>> exportAll() async {
    final profile = await profileDao.getProfile();
    final wardrobe = await wardrobeDao.getAvailable();
    final outfitRows = await (outfitDao.watchAll().first);
    final measurements = await measurementDao.getAll();
    final xpEvents = await rpgDao.getAllXpEvents();
    final habits = (await habitsDao.watchAll().first);
    final purchases = (await purchasesDao.watchAll().first);
    final health = await healthDao.getAll();

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile == null
          ? null
          : {
              'height': profile.height,
              'weight': profile.weight,
              'waist': profile.waist,
              'chest': profile.chest,
              'hips': profile.hips,
              'shoulders': profile.shoulders,
              'neck': profile.neck,
              'shoeSize': profile.shoeSize,
              'stylePreferences': profile.stylePreferences,
              'colorPreferences': profile.colorPreferences,
              'budgetTier': profile.budgetTier,
            },
      'wardrobe': wardrobe
          .map((w) => {
                'id': w.id,
                'name': w.name,
                'category': w.category,
                'brand': w.brand,
                'size': w.size,
                'color': w.color,
                'material': w.material,
                'season': w.season,
                'fit': w.fit,
                'price': w.price,
                'notes': w.notes,
                'condition': w.condition,
                'rating': w.rating,
                'wearCount': w.wearCount,
                'createdAt': w.createdAt.toIso8601String(),
              })
          .toList(),
      'outfits': outfitRows
          .map((o) => {
                'id': o.id,
                'name': o.name,
                'occasion': o.occasion,
                'dressCode': o.dressCode,
                'season': o.season,
                'score': o.score,
                'createdAt': o.createdAt.toIso8601String(),
              })
          .toList(),
      'measurements': measurements
          .map((m) => {
                'id': m.id,
                'date': m.date.toIso8601String(),
                'weight': m.weight,
                'waist': m.waist,
                'chest': m.chest,
                'hips': m.hips,
              })
          .toList(),
      'xpEvents': xpEvents
          .map((e) => {
                'id': e.id,
                'type': e.type,
                'amount': e.amount,
                'reason': e.reason,
                'createdAt': e.createdAt.toIso8601String(),
              })
          .toList(),
      'habits': habits
          .map((h) => {
                'id': h.id,
                'title': h.title,
                'streak': h.streak,
                'active': h.active,
                'period': h.period,
              })
          .toList(),
      'purchases': purchases
          .map((p) => {
                'id': p.id,
                'itemName': p.itemName,
                'category': p.category,
                'priority': p.priority,
                'budget': p.budget,
                'status': p.status,
              })
          .toList(),
      'health': health
          .map((h) => {
                'id': h.id,
                'type': h.type,
                'value': h.value,
                'date': h.date.toIso8601String(),
                'note': h.note,
              })
          .toList(),
    };
  }

  Future<File> exportToFile(String dirPath) async {
    final data = await exportAll();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
    final file = File('$dirPath/gentleman_os_export_$timestamp.json');
    await file.writeAsString(json);
    return file;
  }
}
