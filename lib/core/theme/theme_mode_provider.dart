import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gentleman_os/core/ai/router_ai_config.dart' show secureStorageProvider;

const String _kThemeMode = 'theme_mode';

/// Режим оформления приложения с сохранением выбора между запусками.
/// По умолчанию — тёмная тема (дизайн dark-first), но пользователь может
/// переключить на светлую или системную в настройках.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark;
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  Future<void> _load() async {
    final raw = await _storage.read(key: _kThemeMode);
    final mode = switch (raw) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      _ => null,
    };
    if (mode != null && mode != state) state = mode;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _kThemeMode, value: mode.name);
  }
}
