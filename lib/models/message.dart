class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final int tabIndex; // Вместо category используем индекс таба

  const Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.tabIndex,
  });
}
