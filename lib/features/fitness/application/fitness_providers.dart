import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';

final measurementListProvider = StreamProvider<List<MeasurementLogsData>>(
  (ref) => ref.watch(measurementDaoProvider).watchAll(),
);

final latestMeasurementProvider = FutureProvider<MeasurementLogsData?>(
  (ref) => ref.watch(measurementDaoProvider).getLatest(),
);
