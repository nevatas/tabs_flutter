import 'package:flutter/material.dart';

class CustomPageController extends PageController {
  CustomPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) : super(
          initialPage: initialPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
        );

  Future<void> animateToPageWithoutBuilding(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    // Мгновенно перемещаемся к целевой странице без анимации
    super.jumpToPage(page);
  }

  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    // Используем стандартную анимацию для соседних страниц
    return super.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }
}
