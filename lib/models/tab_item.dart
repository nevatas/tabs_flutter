class TabItem {
  final String title;
  final String emoji;

  const TabItem({
    required this.title,
    required this.emoji,
  });

  static const List<TabItem> defaultTabs = [
    TabItem(title: 'Inbox', emoji: '📥'),
    TabItem(title: 'Books', emoji: '📚'),
    TabItem(title: 'Ideas', emoji: '💡'),
    TabItem(title: 'Words', emoji: '📝'),
    TabItem(title: 'Quotes', emoji: '💭'),
  ];
}
