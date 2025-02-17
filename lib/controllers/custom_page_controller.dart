import 'package:flutter/material.dart';

class CustomPageController extends PageController {
  bool _isUserGesture = false;

  CustomPageController({
    int initialPage = 0,
    bool keepPage = true,
  }) : super(
         initialPage: initialPage,
         keepPage: keepPage,
       );

  Future<void> animateToPageWithoutBuilding(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    _isUserGesture = false;
    super.jumpToPage(page);
  }

  @override
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    _isUserGesture = false;
    return super.animateToPage(
      page,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeIn,
    );
  }

  // Переопределяем метод для отслеживания пользовательских жестов
  @override
  bool get hasClients => super.hasClients;

  @override
  double get page => super.page ?? 0.0;

  void startUserGesture() {
    _isUserGesture = true;
  }

  bool get isUserGesture => _isUserGesture;
}
