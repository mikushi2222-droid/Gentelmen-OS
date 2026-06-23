import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/app.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

void main() {
  // Запускаем всё в охраняемой зоне, чтобы любое необработанное исключение
  // (в т.ч. из async-кода) попало в журнал отладки, а не только в консоль.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Ошибки фреймворка Flutter (build/layout/paint) → в журнал.
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        log.e(
          'Flutter',
          details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
        );
        prevOnError?.call(details);
      };

      // Необработанные ошибки платформы/движка → в журнал.
      PlatformDispatcher.instance.onError = (error, stack) {
        log.e('App', 'Необработанное исключение',
            error: error, stackTrace: stack);
        return true;
      };

      log.i('App', 'Запуск Gentleman OS');

      final db = AppDatabase();

      runApp(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const GentlemanApp(),
        ),
      );
    },
    (error, stack) {
      log.e('App', 'Неперехваченная ошибка зоны',
          error: error, stackTrace: stack);
    },
  );
}
