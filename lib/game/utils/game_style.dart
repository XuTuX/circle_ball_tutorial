import 'package:flutter/material.dart';

class GameStyle {
  // Colors
  static const Color paperBackground = Color(0xFFF9F6EE); // Off-white paper color
  static const Color inkBlack = Color(0xFF1A1A1A);
  
  // Primary Colors (High Contrast)
  static const Color primaryRed = Color(0xFFFF4D4D);
  static const Color primaryBlue = Color(0xFF4D79FF);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color primaryGreen = Color(0xFF6BCB77);
  static const Color primaryOrange = Color(0xFFFF9F43);

  // Paints
  static Paint inkOutlinePaint(double width) => Paint()
    ..color = inkBlack
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  static Paint fillPaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // Text Styles
  static TextStyle cartoonStyle({
    required double fontSize,
    Color color = inkBlack,
    bool shadowed = true,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w900,
      fontFamily: 'Courier', // Using Courier as a placeholder for sketch feel if no custom font
      shadows: shadowed ? [
        const Shadow(
          offset: Offset(2, 2),
          color: Color(0x40000000),
          blurRadius: 0,
        ),
      ] : null,
    );
  }

  static BoxDecoration paperPanelDecoration = BoxDecoration(
    color: paperBackground,
    border: Border.all(color: inkBlack, width: 4),
    boxShadow: const [
      BoxShadow(
        color: inkBlack,
        offset: Offset(6, 6),
      ),
    ],
  );

  static BoxDecoration buttonDecoration = BoxDecoration(
    color: primaryYellow,
    border: Border.all(color: inkBlack, width: 3),
    boxShadow: const [
      BoxShadow(
        color: inkBlack,
        offset: Offset(4, 4),
      ),
    ],
  );
}
