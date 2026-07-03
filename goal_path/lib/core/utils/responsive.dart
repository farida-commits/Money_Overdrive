import 'package:flutter/material.dart';

/// Утилита для адаптивных размеров.
/// Использование: Responsive.width(context, 0.9) — 90% ширины экрана
class Responsive {
  Responsive._();

  static double width(BuildContext context, double fraction) {
    return MediaQuery.of(context).size.width * fraction;
  }

  static double height(BuildContext context, double fraction) {
    return MediaQuery.of(context).size.height * fraction;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}