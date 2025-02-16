// widgets/side_menu.dart
import 'package:flutter/material.dart';
import 'side_menu_tab.dart';
import '../models/tab_item.dart';

class SideMenu extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const SideMenu({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...List.generate(
              tabs.length,
              (index) => SideMenuTab(
                title: tabs[index].title,
                emoji: tabs[index].emoji,
                isSelected: index == selectedIndex,
                onTap: () {
                  onTabSelected(index);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
