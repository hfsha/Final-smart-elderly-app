import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Trust + Safety)
  static const Color primary = Color(0xFF2E5A88); // Navy Blue (Professional, reliable)
  static const Color teal = Color(0xFF3AA8A1); // Teal (Health/tech vibe – ideal for active elements)
  static const Color softWhite = Color(0xFFF8F9FA); // Soft White (Background for readability)

  // Secondary Colors (Alerts + Action)
  static const Color coral = Color(0xFFFF6B6B); // Coral (For urgent alerts – softer than harsh red)
  static const Color sunshineYellow = Color(0xFFFFD166); // Sunshine Yellow (Warnings – less alarming than orange)
  static const Color mintGreen = Color(0xFFa2d9a1); // Mint Green (Safe/OK status – gentle on aging eyes)

  // Accessibility-Friendly Contrast
  static const Color charcoal = Color(0xFF333333); // Charcoal (Text on light backgrounds)
  static const Color lightGray = Color(0xFFE9ECEF); // Light Gray (Disabled buttons/divider lines)

  // Existing colors that might be remapped or removed based on the new palette
  static const Color primaryDark = Color(0xFF000051); // Remap or remove if not needed
  static const Color primaryLight = Color(0xFF534bae); // Remap or remove if not needed
  static const Color secondary = Color(0xFF009688); // Remap or remove if not needed
  static const Color secondaryDark = Color(0xFF00675b); // Remap or remove if not needed
  static const Color secondaryLight = Color(0xFF52c7b8); // Remap or remove if not needed
  static const Color success = Color(0xFF4CAF50); // Remap to mintGreen
  static const Color warning = Color(0xFFFF9800); // Remap to sunshineYellow
  static const Color danger = Color(0xFFF44336); // Remap to coral
  static const Color info = Color(0xFF2196F3); // Remap or remove if not needed
  static const Color backgroundLight = Color(0xFFf5f5f5); // Remap to softWhite
  static const Color backgroundDark = Color(0xFF121212); // Remap or remove if not needed
  static const Color cardBackground = Color(0xFFFFFFFF); // Remap to softWhite or remove if glassmorphism handles it
  static const Color dividerColor = Color(0xFFE0E0E0); // Remap to lightGray
  static const Color textPrimary = Color(0xFF212121); // Remap to charcoal
  static const Color textSecondary = Color(0xFF757575); // Remap to charcoal or a lighter gray for secondary text
  static const Color textLight = Color(0xFFf5f5f5); // Remap or remove if not needed
  static const Color gradientPurple = Color(0xFF8F5CFF); // Vibrant purple for gradients
  static const Color gradientBlue = Color(0xFF3A8DFF); // Vibrant blue for gradients
}
