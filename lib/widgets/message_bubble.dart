import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onSelect;

  MessageBubble({
    super.key,
    required this.message,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onLongPress,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: isSelectionMode ? onSelect : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isSelectionMode ? 1 : 0,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.5, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12, top: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.getAccentBackground(context)
                                  : AppColors.getDividedColor(context),
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.getAccentBackground(context)
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getSecondaryBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.getTertiaryBackground(context),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: AppColors.getPrimaryText(context),
                      letterSpacing: 0.2,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
