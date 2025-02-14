enum MessageCategory { inbox, books, ideas, words, quotes }

class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageCategory category;

  Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.category,
  });
}
