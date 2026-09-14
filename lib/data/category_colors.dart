import 'package:flutter/material.dart';

/// Consistent color mapping for each challenge category
class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> colors = {
    'domestic': Color(0xFFFF6B6B), // Coral Red
    'dirty_truth': Color(0xFF45B7D1), // Sky Blue
    'spicy_dare': Color(0xFFFF8C42), // Burnt Orange
    'roleplay': Color(0xFFA855F7), // Vivid Purple
    'sensation': Color(0xFFFFE66D), // Electric Yellow
    'wildcard': Color(0xFF4ECDC4), // Teal
  };

  static const Map<String, Color> darkColors = {
    'domestic': Color(0xFFCC4444),
    'dirty_truth': Color(0xFF227799),
    'spicy_dare': Color(0xFFCC6622),
    'roleplay': Color(0xFF7733BB),
    'sensation': Color(0xFFCCAA22),
    'wildcard': Color(0xFF229999),
  };

  static Color get(String categoryId) {
    return colors[categoryId] ?? Colors.grey;
  }

  static Color getDark(String categoryId) {
    return darkColors[categoryId] ?? Colors.grey.shade800;
  }

  static Color getHslAdjusted(String categoryId, double hueShift) {
    final hsl = HSLColor.fromColor(get(categoryId));
    return hsl.withHue((hsl.hue + hueShift) % 360).toColor();
  }
}
