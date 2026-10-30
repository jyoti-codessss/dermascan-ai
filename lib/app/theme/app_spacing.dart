import 'package:flutter/widgets.dart';

/// Spacing scale constants according to design.md (#5 & #12).
abstract final class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Semantic paddings
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl, vertical: md);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(md);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xl, vertical: 14.0);
}
