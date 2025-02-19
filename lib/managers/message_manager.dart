import '../models/message.dart';
import '../services/storage_service.dart';

class MessageManager {
  final StorageService _storage;
  final Map<int, List<Message>> messagesByTabIndex = {};
  final Map<int, bool> isLoading = {};
  final Map<int, DateTime?> lastMessageTime = {};
  final Set<Message> selectedMessages = {};
  bool isSelectionMode = false;

  MessageManager(this._storage);

  Future<void> initialize() async {
    await _storage.init();
    // Инициализируем isLoading для Inbox
    isLoading[0] = false;
    await loadMoreMessages(0);
  }

  Future<void> sendMessage(Message message) async {
    await _storage.saveMessage(message);
    messagesByTabIndex[message.tabIndex] ??= [];
    messagesByTabIndex[message.tabIndex]!.insert(0, message);
  }

  Future<void> loadMoreMessages(int tabIndex) async {
    // Инициализируем isLoading для нового таба, если его еще нет
    isLoading[tabIndex] ??= false;

    if (isLoading[tabIndex] == true) return;

    isLoading[tabIndex] = true;
    try {
      final messages = await _storage.loadMessages(
        tabIndex,
        before: lastMessageTime[tabIndex],
      );

      if (messages.isNotEmpty) {
        messagesByTabIndex[tabIndex] ??= [];
        messagesByTabIndex[tabIndex]!.addAll(messages);
        lastMessageTime[tabIndex] = messages.last.timestamp;
      }
    } finally {
      isLoading[tabIndex] = false;
    }
  }

  Future<void> deleteMessage(Message message) async {
    await _storage.deleteMessage(message);
    messagesByTabIndex[message.tabIndex]?.remove(message);
    selectedMessages.remove(message);
  }

  Future<void> moveMessage(Message message, int newTabIndex) async {
    await _storage.moveMessage(message, newTabIndex);
    messagesByTabIndex[message.tabIndex]?.remove(message);
    selectedMessages.remove(message);

    // Создаем новое сообщение с обновленным tabIndex
    final newMessage = Message(
      text: message.text,
      isMe: message.isMe,
      timestamp: message.timestamp,
      tabIndex: newTabIndex,
    );

    messagesByTabIndex[newTabIndex] ??= [];
    messagesByTabIndex[newTabIndex]!.insert(0, newMessage);
  }

  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    if (!isSelectionMode) {
      selectedMessages.clear();
    }
  }

  void toggleMessageSelection(Message message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
  }
}
