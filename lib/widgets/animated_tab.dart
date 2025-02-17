import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import '../models/tab_item.dart';
import '../theme/app_colors.dart';

class AnimatedTab extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> animation;
  final Offset startPosition;
  final Offset endPosition;
  final double startWidth;
  final double endWidth;

  const AnimatedTab({
    super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.animation,
    required this.startPosition,
    required this.endPosition,
    required this.startWidth,
    required this.endWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final position =
            Offset.lerp(startPosition, endPosition, animation.value)!;
        final width = lerpDouble(startWidth, endWidth, animation.value)!;

        return Positioned(
          left: position.dx,
          top: position.dy,
          width: width,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.getSecondaryBackground(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.getTertiaryBackground(context)
                    : Colors.transparent,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        tab.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        tab.title,
                        style: TextStyle(
                          color: AppColors.getPrimaryText(context),
                          fontSize: 17,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
