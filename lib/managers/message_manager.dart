import '../models/message.dart';
import '../services/storage_service.dart';

class MessageManager {
  final StorageService _storage;
  final Map<MessageCategory, List<Message>> messagesByCategory = {
    MessageCategory.inbox: [],
    MessageCategory.books: [],
    MessageCategory.ideas: [],
    MessageCategory.words: [],
    MessageCategory.quotes: [],
  };

  final Map<MessageCategory, bool> hasMoreMessages = {
    for (var category in MessageCategory.values) category: true
  };

  final Map<MessageCategory, bool> isLoading = {
    for (var category in MessageCategory.values) category: false
  };

  MessageManager(this._storage);

  Future<void> initialize() async {
    await _storage.init();
    for (var category in MessageCategory.values) {
      messagesByCategory[category] = [];
      isLoading[category] = false;
      await loadMoreMessages(category);
    }
  }

  Future<void> sendMessage(Message message) async {
    messagesByCategory[message.category]!.add(message);

    try {
      await _storage.saveMessage(message);
    } catch (e) {
      messagesByCategory[message.category]!.removeLast();
      rethrow;
    }
  }

  Future<void> moveMessage(Message message, MessageCategory newCategory) async {
    messagesByCategory[message.category]!.remove(message);

    try {
      await _storage.moveMessage(message, newCategory);
      final newMessage = Message(
        text: message.text,
        isMe: message.isMe,
        timestamp: message.timestamp,
        category: newCategory,
      );
      messagesByCategory[newCategory]!.insert(0, newMessage);
    } catch (e) {
      messagesByCategory[message.category]!.add(message);
      rethrow;
    }
  }

  Future<void> deleteMessage(Message message) async {
    messagesByCategory[message.category]!.remove(message);

    try {
      await _storage.deleteMessage(message);
    } catch (e) {
      messagesByCategory[message.category]!.add(message);
      rethrow;
    }
  }

  Future<void> loadMoreMessages(MessageCategory category) async {
    if (isLoading[category]! || !hasMoreMessages[category]!) return;

    isLoading[category] = true;

    try {
      final messages = await _storage.loadMessages(
        category,
        limit: 20,
        before: messagesByCategory[category]!.isEmpty
            ? null
            : messagesByCategory[category]!.last.timestamp,
      );

      messagesByCategory[category]!.addAll(messages);
      hasMoreMessages[category] = messages.length == 20;
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoading[category] = false;
    }
  }
}
