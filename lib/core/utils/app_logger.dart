import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Уровни логирования.
enum LogLevel { debug, info, warning, error }

extension LogLevelX on LogLevel {
  String get label => switch (this) {
        LogLevel.debug => 'DEBUG',
        LogLevel.info => 'INFO',
        LogLevel.warning => 'WARN',
        LogLevel.error => 'ERROR',
      };

  /// Severity для dart:developer.log (по аналогии с logging package).
  int get severity => switch (this) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      };
}

/// Одна запись лога.
class LogEntry {
  LogEntry({
    required this.time,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime time;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  String get formatted {
    final t = time.toIso8601String().substring(11, 23); // HH:mm:ss.SSS
    final base = '$t ${level.label.padRight(5)} [$tag] $message';
    return error != null ? '$base\n    ↳ $error' : base;
  }

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'level': level.label,
        'tag': tag,
        'message': message,
        if (error != null) 'error': error.toString(),
      };
}

/// Глобальный логгер приложения.
///
/// - Печатает в консоль через `dart:developer.log` (видно в DevTools/logcat).
/// - Хранит последние [_maxEntries] записей в кольцевом буфере — их можно
///   показать на экране отладки и приложить к багрепорту/экспорту.
/// - Минимальный уровень в release повышается до [LogLevel.info].
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const int _maxEntries = 500;
  final Queue<LogEntry> _buffer = Queue<LogEntry>();

  /// Минимальный уровень для записи (в release не пишем debug).
  LogLevel minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug;

  /// Подписчики (например, экран логов) для live-обновления.
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);

  UnmodifiableListView<LogEntry> get entries =>
      UnmodifiableListView(_buffer.toList());

  void log(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;

    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _buffer.addLast(entry);
    while (_buffer.length > _maxEntries) {
      _buffer.removeFirst();
    }

    developer.log(
      message,
      time: entry.time,
      level: level.severity,
      name: 'gentleman_os.$tag',
      error: error,
      stackTrace: stackTrace,
    );

    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
  }

  void d(String tag, String message) => log(LogLevel.debug, tag, message);
  void i(String tag, String message) => log(LogLevel.info, tag, message);
  void w(String tag, String message, {Object? error}) =>
      log(LogLevel.warning, tag, message, error: error);
  void e(String tag, String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);

  void clear() {
    _buffer.clear();
    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
  }

  /// Весь буфер в виде текста — для копирования/экспорта.
  String dumpText() => _buffer.map((e) => e.formatted).join('\n');
}

/// Короткий алиас для использования по всему приложению.
final log = AppLogger.instance;
