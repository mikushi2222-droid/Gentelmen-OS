import 'dart:io';

import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Каталог внутри documents-директории приложения, где постоянно хранятся
/// фотографии вещей гардероба.
const String _kWardrobeDir = 'wardrobe_images';
const String _tag = 'ImageStorage';

/// Копирует выбранное фото из временного кэша `image_picker` в постоянный
/// каталог приложения и возвращает новый путь.
///
/// `image_picker` возвращает путь во временной директории, которую ОС вправе
/// очистить в любой момент — поэтому исходный путь нельзя сохранять в БД.
Future<String> persistWardrobeImage(String sourcePath) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, _kWardrobeDir));
  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }
  final ext = p.extension(sourcePath);
  final dest = p.join(dir.path, '${const Uuid().v4()}$ext');
  await File(sourcePath).copy(dest);
  log.d(_tag, 'Фото сохранено: $dest');
  return dest;
}

/// Удаляет файл изображения вещи, если он лежит в нашем постоянном каталоге.
/// Безопасно игнорирует внешние пути и отсутствующие файлы.
Future<void> deleteWardrobeImage(String? path) async {
  if (path == null) return;
  if (p.basename(p.dirname(path)) != _kWardrobeDir) return;
  final file = File(path);
  if (!file.existsSync()) return;
  try {
    await file.delete();
    log.d(_tag, 'Фото удалено: $path');
  } on Object catch (err) {
    log.w(_tag, 'Не удалось удалить фото', error: err);
  }
}
