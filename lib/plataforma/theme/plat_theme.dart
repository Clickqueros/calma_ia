import 'package:flutter/material.dart';

class PlatTheme {
  PlatTheme._();

  static const Color darkNavy    = Color(0xFF0D0A35);
  static const Color navyPurple  = Color(0xFF1A1464);
  static const Color purple      = Color(0xFF6B4EFF);
  static const Color softPurple  = Color(0xFF9B8FFF);
  static const Color textDark    = Color(0xFF1A1A2E);
  static const Color textGray    = Color(0xFF6B7280);
  static const Color softBlue    = Color(0xFFB0BFFF);
  static const Color softBg      = Color(0xFFF8F7FF);

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNavy, Color(0xFF2D1B69), navyPurple],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, softPurple],
  );
}
