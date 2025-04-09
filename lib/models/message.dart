class Message {
  final String text;
  final DateTime timestamp;
  final int tabIndex; // Вместо category используем индекс таба

  const Message({
    required this.text,
    required this.timestamp,
    required this.tabIndex,
  });
}
