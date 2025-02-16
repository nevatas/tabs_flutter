// widgets/side_menu.dart
import 'package:flutter/material.dart';
import 'side_menu_tab.dart';

class SideMenu extends StatelessWidget {
  final List<String> tabs;
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
                title: tabs[index],
                emoji: _getEmojiForTab(index),
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

  String _getEmojiForTab(int index) {
    switch (index) {
      case 0:
        return '📥';
      case 1:
        return '📚';
      case 2:
        return '💡';
      case 3:
        return '📝';
      case 4:
        return '💭';
      default:
        return '📁';
    }
  }
}
