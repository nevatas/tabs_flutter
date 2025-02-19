import 'package:flutter/material.dart';

class SideMenuTab extends StatelessWidget {
  final String title;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const SideMenuTab({
    super.key,
    required this.title,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: emoji != null
          ? Container(
              alignment: Alignment.center,
              width: 40,
              child: Text(
                emoji!,
                style: const TextStyle(fontSize: 24),
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
          letterSpacing: -0.2,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
