// services/storage_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/message.dart';

class StorageService {
  late final Directory _baseDir;
  static const String _extension = '.md';

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory(path.join(appDir.path, 'notes'));
    if (!await _baseDir.exists()) {
      await _baseDir.create(recursive: true);
    }
  }

  Future<Directory> _getTabDir(int tabIndex) async {
    final dir = Directory(path.join(_baseDir.path, 'tab_$tabIndex'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> saveMessage(Message message) async {
    final tabDir = await _getTabDir(message.tabIndex);
    final fileName = '${message.timestamp.millisecondsSinceEpoch}$_extension';
    final file = File(path.join(tabDir.path, fileName));

    // Создаем markdown контент
    final content = '''
---
timestamp: ${message.timestamp.toIso8601String()}
tabIndex: ${message.tabIndex}
isMe: ${message.isMe}
---

${message.text}
''';

    await file.writeAsString(content);
  }

  Future<List<Message>> loadMessages(
    int tabIndex, {
    int limit = 20,
    DateTime? before,
  }) async {
    final tabDir = await _getTabDir(tabIndex);
    final files = await tabDir
        .list()
        .where((entity) =>
            entity is File && path.extension(entity.path) == _extension)
        .toList();

    // Сортируем файлы по имени (timestamp) в обратном порядке
    files.sort((a, b) => b.path.compareTo(a.path));

    // Применяем пагинацию
    if (before != null) {
      files.removeWhere((file) {
        final fileName = path.basenameWithoutExtension(file.path);
        return int.parse(fileName) >= before.millisecondsSinceEpoch;
      });
    }

    final messages = <Message>[];

    // Загружаем только необходимое количество файлов
    for (var i = 0; i < limit && i < files.length; i++) {
      final file = files[i] as File;
      try {
        final content = await file.readAsString();
        final message = _parseMessageFromMd(content);
        messages.add(message);
      } catch (e) {
        print('Error reading file: ${file.path}');
        // Можно добавить более продвинутую обработку ошибок
      }
    }

    return messages;
  }

  Future<void> moveMessage(Message message, int newTabIndex) async {
    final oldDir = await _getTabDir(message.tabIndex);
    final fileName = '${message.timestamp.millisecondsSinceEpoch}$_extension';
    final oldFile = File(path.join(oldDir.path, fileName));
    // Убираем неиспользуемую переменную newFile

    // Создаем новое сообщение с обновленной категорией
    final newMessage = Message(
      text: message.text,
      isMe: message.isMe,
      timestamp: message.timestamp,
      tabIndex: newTabIndex,
    );

    // Сохраняем новое сообщение и удаляем старое
    await saveMessage(newMessage);
    if (await oldFile.exists()) {
      await oldFile.delete();
    }
  }

  Future<void> deleteMessage(Message message) async {
    final tabDir = await _getTabDir(message.tabIndex);
    final fileName = '${message.timestamp.millisecondsSinceEpoch}$_extension';
    final file = File(path.join(tabDir.path, fileName));

    if (await file.exists()) {
      await file.delete();
    }
  }

  Message _parseMessageFromMd(String content) {
    final parts = content.split('---');
    if (parts.length < 3) {
      throw FormatException('Invalid markdown format');
    }

    // Парсим метаданные
    final metadata = parts[1].trim().split('\n');
    DateTime? timestamp;
    bool isMe = false;
    int tabIndex = 0;

    for (final line in metadata) {
      final keyValue = line.split(': ');
      if (keyValue.length != 2) continue;

      final key = keyValue[0].trim();
      final value = keyValue[1].trim();

      switch (key) {
        case 'timestamp':
          timestamp = DateTime.parse(value);
          break;
        case 'isMe':
          isMe = value.toLowerCase() == 'true';
          break;
        case 'tabIndex':
          tabIndex = int.parse(value);
          break;
      }
    }

    // Получаем текст сообщения
    final text = parts[2].trim();

    if (timestamp == null) {
      throw FormatException('Timestamp is required');
    }

    return Message(
      text: text,
      isMe: isMe,
      timestamp: timestamp,
      tabIndex: tabIndex,
    );
  }

  Future<bool> hasMoreMessages(
    int tabIndex,
    DateTime before,
  ) async {
    final tabDir = await _getTabDir(tabIndex);
    final files = await tabDir
        .list()
        .where((entity) =>
            entity is File &&
            path.extension(entity.path) == _extension &&
            int.parse(path.basenameWithoutExtension(entity.path)) <
                before.millisecondsSinceEpoch)
        .toList();

    return files.isNotEmpty;
  }
}
