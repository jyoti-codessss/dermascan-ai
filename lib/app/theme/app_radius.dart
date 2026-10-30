import 'package:flutter/widgets.dart';

/// Border radius tokens according to design.md (#6 & #13).
abstract final class AppRadius {
  static const double xsValue = 4.0;
  static const double smValue = 8.0;
  static const double mdValue = 12.0;
  static const double lgValue = 16.0;
  static const double xlValue = 20.0;
  static const double xxlValue = 24.0;
  static const double pillValue = 999.0;

  // BorderRadius objects
  static const BorderRadius xs = BorderRadius.all(Radius.circular(xsValue));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(lgValue));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(xxlValue));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(pillValue));

  // Semantic radius
  static const BorderRadius button = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius input = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lgValue));
  static const BorderRadius featureCard = BorderRadius.all(Radius.circular(xxlValue));
  static const BorderRadius statusBadge = BorderRadius.all(Radius.circular(pillValue));
}
