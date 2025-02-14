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

  Future<Directory> _getCategoryDir(MessageCategory category) async {
    final dir = Directory(path.join(_baseDir.path, category.name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> saveMessage(Message message) async {
    final categoryDir = await _getCategoryDir(message.category);
    final fileName = '${message.timestamp.millisecondsSinceEpoch}$_extension';
    final file = File(path.join(categoryDir.path, fileName));

    // Создаем markdown контент
    final content = '''
---
timestamp: ${message.timestamp.toIso8601String()}
category: ${message.category.name}
isMe: ${message.isMe}
---

${message.text}
''';

    await file.writeAsString(content);
  }

  Future<List<Message>> loadMessages(
    MessageCategory category, {
    int limit = 20,
    DateTime? before,
  }) async {
    final categoryDir = await _getCategoryDir(category);
    final files = await categoryDir
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
        final message = _parseMessageFromMd(content, category);
        messages.add(message);
      } catch (e) {
        print('Error reading file: ${file.path}');
        // Можно добавить более продвинутую обработку ошибок
      }
    }

    return messages;
  }

  Message _parseMessageFromMd(String content, MessageCategory category) {
    final parts = content.split('---');
    if (parts.length < 3) {
      throw FormatException('Invalid markdown format');
    }

    // Парсим метаданные
    final metadata = parts[1].trim().split('\n');
    DateTime? timestamp;
    bool isMe = false;

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
      category: category,
    );
  }

  Future<bool> hasMoreMessages(
    MessageCategory category,
    DateTime before,
  ) async {
    final categoryDir = await _getCategoryDir(category);
    final files = await categoryDir
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
