import 'package:flutter/material.dart';
import '../controllers/custom_page_controller.dart';
import '../models/tab_item.dart';

class TabManager {
  List<TabItem> _tabs = TabItem.defaultTabs;
  List<TabItem> get tabs => _tabs;

  final CustomPageController pageController;
  final Map<int, ScrollController> scrollControllers = {};
  int selectedTabIndex;
  int? pendingTabIndex;

  TabManager({
    required this.pageController,
    this.selectedTabIndex = 0,
  }) {
    _initScrollControllers();
  }

  void _initScrollControllers() {
    for (var i = 0; i < _tabs.length; i++) {
      scrollControllers[i] = ScrollController();
    }
  }

  void handleTabSelection(int index, {bool fromDrawer = false}) {
    print('🔵 TabManager.handleTabSelection:');
    print('  Старый индекс: $selectedTabIndex');
    print('  Новый индекс: $index');
    print('  fromDrawer: $fromDrawer');

    final oldIndex = selectedTabIndex;
    selectedTabIndex = index;

    if (pageController.hasClients) {
      final difference = (index - oldIndex).abs();
      if (difference > 1) {
        print('  Используем animateToPageWithoutBuilding');
        pageController.animateToPageWithoutBuilding(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } else {
        print('  Используем animateToPage');
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void updateTabs(List<TabItem> newTabs) {
    print('🔵 TabManager.updateTabs:');
    print(
        '  Текущие табы: ${_tabs.map((t) => "${t.emoji ?? ''} ${t.title}").toList()}');
    print(
        '  Новые табы: ${newTabs.map((t) => "${t.emoji ?? ''} ${t.title}").toList()}');

    assert(
        newTabs.isNotEmpty && newTabs.first.isInbox, 'First tab must be Inbox');

    // Проверяем, действительно ли изменился список табов
    if (_tabs.length != newTabs.length ||
        !_tabs.asMap().entries.every((entry) =>
            entry.value.title == newTabs[entry.key].title &&
            entry.value.emoji == newTabs[entry.key].emoji)) {
      _tabs = newTabs;

      // Очищаем старые контроллеры
      for (var controller in scrollControllers.values) {
        controller.dispose();
      }
      scrollControllers.clear();

      // Инициализируем контроллеры для всех табов
      for (var i = 0; i < newTabs.length; i++) {
        scrollControllers[i] = ScrollController();
      }
    }

    // Убираем автоматическое переключение страницы отсюда
    // Теперь это будет делаться через handleTabSelection
  }

  void dispose() {
    pageController.dispose();
    for (var controller in scrollControllers.values) {
      controller.dispose();
    }
  }
}
