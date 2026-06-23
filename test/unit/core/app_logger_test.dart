import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

void main() {
  late AppLogger logger;

  setUp(() {
    logger = AppLogger.instance;
    logger.minLevel = LogLevel.debug;
    logger.clear();
  });

  group('AppLogger', () {
    test('записывает событие в буфер', () {
      logger.i('Test', 'привет');
      expect(logger.entries, hasLength(1));
      expect(logger.entries.single.message, 'привет');
      expect(logger.entries.single.level, LogLevel.info);
      expect(logger.entries.single.tag, 'Test');
    });

    test('отфильтровывает уровни ниже minLevel', () {
      logger.minLevel = LogLevel.warning;
      logger.d('Test', 'debug');
      logger.i('Test', 'info');
      logger.w('Test', 'warn');
      logger.e('Test', 'error');
      expect(logger.entries.map((e) => e.level),
          [LogLevel.warning, LogLevel.error]);
    });

    test('кольцевой буфер не превышает лимит и хранит свежие записи', () {
      for (var i = 0; i < 600; i++) {
        logger.d('Test', 'msg $i');
      }
      expect(logger.entries, hasLength(500));
      // Самые старые вытеснены — остаётся последняя запись.
      expect(logger.entries.last.message, 'msg 599');
      expect(logger.entries.first.message, 'msg 100');
    });

    test('ошибка попадает в formatted', () {
      logger.e('Test', 'упало', error: StateError('boom'));
      final entry = logger.entries.single;
      expect(entry.error, isA<StateError>());
      expect(entry.formatted, contains('упало'));
      expect(entry.formatted, contains('boom'));
    });

    test('dumpMarkdown содержит заголовок, сводку и записи', () {
      logger.i('Nav', 'Переход: /dashboard');
      logger.e('App', 'упало', error: StateError('boom'));

      final md = logger.dumpMarkdown();
      expect(md, contains('# Журнал отладки Gentleman OS'));
      expect(md, contains('Всего записей: 2'));
      expect(md, contains('INFO: 1'));
      expect(md, contains('ERROR: 1'));
      expect(md, contains('Переход: /dashboard'));
      expect(md, contains('boom'));
      expect(md, contains('```text'));
    });

    test('clear очищает буфер', () {
      logger.i('Test', 'a');
      logger.clear();
      expect(logger.entries, isEmpty);
    });

    test('уведомляет подписчиков о новых записях и очистке', () {
      var calls = 0;
      void listener() => calls++;
      logger.addListener(listener);
      addTearDown(() => logger.removeListener(listener));

      logger.i('Test', 'a');
      logger.clear();
      expect(calls, 2);
    });
  });
}
