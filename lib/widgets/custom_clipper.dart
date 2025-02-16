import 'package:flutter/material.dart';

class TopClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, size.height * 0.3, size.width, size.height);
  }

  @override
  bool shouldReclip(TopClipper oldClipper) => false;
}
