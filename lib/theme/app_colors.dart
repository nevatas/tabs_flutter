import 'package:flutter/material.dart';

class AppColors {
  static const Color _secondaryBackgroundDark = Color(0xFF191919);
  static const Color _secondaryBackgroundLight = Color(0xFFF1F1F1);

  static const Color _primaryBackgroundDark = Color(0xFF070707);
  static const Color _primaryBackgroundLight = Color(0xFFE2E2E2);

  static const Color _accentBackgroundDark = Color(0xFF467DE9);
  static const Color _accentBackgroundLight = Color(0xFF467DE9);

  static const Color _accentTextDark = Color(0xFFE5E5E5);
  static const Color _accentTextLight = Color(0xFFE5E5E5);

  static const Color _primaryTextDark = Color(0xFFE7E7E7);
  static const Color _primaryTextLight = Color(0xFF1C1C1C);

  static const Color _tertiaryBackgroundDark = Color(0xFF222222);
  static const Color _tertiaryBackgroundLight = Color(0xFFF8F8F8);

  static const Color _secondaryTextDark = Color(0xFF707070);
  static const Color _secondaryTextLight = Color(0xFF9B9B9B);

  static const Color _dividedColorDark = Color(0xFFFFFFFF);
  static const Color _dividedColorLight = Color(0x14000000);

  static const Color _successColorDark = Color(0xFF32B332);
  static const Color _successColorLight = Color(0xFF32B332);

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _primaryBackgroundDark,
    colorScheme: ColorScheme.dark(
      background: _primaryBackgroundDark,
      primary: _primaryBackgroundDark,
      secondary: _secondaryBackgroundDark,
      tertiary: _tertiaryBackgroundDark,
      surface: _secondaryBackgroundDark,
      onBackground: _primaryTextDark,
      onPrimary: _primaryTextDark,
      onSecondary: _secondaryTextDark,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: _primaryTextDark),
      bodyMedium: TextStyle(color: _secondaryTextDark),
    ),
    dividerColor: _dividedColorDark.withOpacity(0.08),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _primaryBackgroundLight,
    colorScheme: ColorScheme.light(
      background: _primaryBackgroundLight,
      primary: _primaryBackgroundLight,
      secondary: _secondaryBackgroundLight,
      tertiary: _tertiaryBackgroundLight,
      surface: _secondaryBackgroundLight,
      onBackground: _primaryTextLight,
      onPrimary: _primaryTextLight,
      onSecondary: _secondaryTextLight,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: _primaryTextLight),
      bodyMedium: TextStyle(color: _secondaryTextLight),
    ),
    dividerColor: _dividedColorLight,
  );

  // Методы для получения цветов в зависимости от темы
  static Color getSecondaryBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _secondaryBackgroundDark
          : _secondaryBackgroundLight;

  static Color getPrimaryBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _primaryBackgroundDark
          : _primaryBackgroundLight;

  static Color getAccentBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _accentBackgroundDark
          : _accentBackgroundLight;

  static Color getAccentText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _accentTextDark
          : _accentTextLight;

  static Color getPrimaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _primaryTextDark
          : _primaryTextLight;

  static Color getTertiaryBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _tertiaryBackgroundDark
          : _tertiaryBackgroundLight;

  static Color getSecondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _secondaryTextDark
          : _secondaryTextLight;

  static Color getDividedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _dividedColorDark
          : _dividedColorLight;

  static Color getSuccessColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _successColorDark
          : _successColorLight;
}
