class TabItem {
  final String title;
  final String? emoji;
  final bool isInbox;

  const TabItem({
    required this.title,
    this.emoji,
    this.isInbox = false,
  });

  static List<TabItem> get defaultTabs => [
        const TabItem(
          title: 'Inbox',
          emoji: '📥',
          isInbox: true,
        ),
      ];
}
