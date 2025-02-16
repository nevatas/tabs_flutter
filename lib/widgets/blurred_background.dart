import 'package:flutter/material.dart';
import 'dart:ui';

class BlurredBackground extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const BlurredBackground({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return BackdropFilter.grouped(
          filter: ImageFilter.blur(
            sigmaX: animation.value * 10,
            sigmaY: animation.value * 10,
          ),
          child: Container(
            color: Colors.white.withOpacity(animation.value * 0.5),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
