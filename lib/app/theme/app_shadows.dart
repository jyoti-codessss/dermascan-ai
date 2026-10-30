import 'package:flutter/widgets.dart';

/// Elevation and shadow tokens according to design.md (#7 & #14).
/// DermaScan AI uses subtle elevation with light borders rather than heavy floating drop shadows.
abstract final class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0C0F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x100F172A),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // Soft AI Glow for SkinOrb and signature elements
  static List<BoxShadow> aiGlow({Color color = const Color(0xFF3B82F6), double opacity = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 24,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
}
