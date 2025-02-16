import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Header extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final bool isSelectionMode;
  final VoidCallback onExitSelectionMode;

  const Header({
    super.key,
    required this.onMenuPressed,
    this.isSelectionMode = false,
    required this.onExitSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryBackground(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.getDividedColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.menu),
            onPressed: isSelectionMode ? onExitSelectionMode : onMenuPressed,
            color: AppColors.getPrimaryText(context),
          ),
          const SizedBox(width: 16),
          Text(
            isSelectionMode ? 'Выбор заметок' : 'Заметки',
            style: TextStyle(
              color: AppColors.getPrimaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
