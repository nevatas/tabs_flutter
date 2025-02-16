// widgets/side_menu.dart
import 'package:flutter/material.dart';

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
              (index) {
                final isSelected = index == selectedIndex;
                return ListTile(
                  leading: Container(
                    alignment: Alignment.center,
                    width: 40,
                    child: Text(
                      _getEmojiForTab(index),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    tabs[index],
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    onTabSelected(index);
                    Navigator.pop(context);
                  },
                );
              },
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
