import 'package:flutter/material.dart';
import '../models/message.dart';
import '../controllers/custom_page_controller.dart';

class TabManager {
  final List<String> tabs = [
    'Inbox',
    'Books',
    'Ideas',
    'Words',
    'Quotes',
  ];

  final CustomPageController pageController;
  final Map<MessageCategory, ScrollController> scrollControllers = {};
  int selectedTabIndex;
  int? pendingTabIndex;

  TabManager({
    required this.pageController,
    this.selectedTabIndex = 0,
  }) {
    for (var category in MessageCategory.values) {
      scrollControllers[category] = ScrollController();
    }
  }

  MessageCategory get currentCategory =>
      MessageCategory.values[selectedTabIndex];

  void handleTabSelection(int index, {bool fromDrawer = false}) {
    if (fromDrawer) {
      pendingTabIndex = index;
      return;
    }

    final oldIndex = selectedTabIndex;
    selectedTabIndex = index;

    if (pageController.hasClients) {
      final difference = (index - oldIndex).abs();
      if (difference > 1) {
        pageController.animateToPageWithoutBuilding(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void dispose() {
    pageController.dispose();
    for (var controller in scrollControllers.values) {
      controller.dispose();
    }
  }

  String getHintTextForCategory(MessageCategory category) {
    switch (category) {
      case MessageCategory.inbox:
        return 'Введите сообщение...';
      case MessageCategory.books:
        return 'Добавьте заметку о книге...';
      case MessageCategory.ideas:
        return 'Запишите свою идею...';
      case MessageCategory.words:
        return 'Добавьте новое слово...';
      case MessageCategory.quotes:
        return 'Введите цитату...';
    }
  }
}
