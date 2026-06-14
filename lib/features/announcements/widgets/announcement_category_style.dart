import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';

class AnnouncementCategoryStyle {
  AnnouncementCategoryStyle._();

  static Color colorFor(String categoryId) {
    final hash = categoryId.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    const palette = [
      AppColors.primary,
      Color(0xFF6A1B9A),
      Color(0xFF2E7D32),
      Color(0xFFE65100),
      Color(0xFF00838F),
    ];
    return palette[hash % palette.length];
  }

  static IconData iconFor(String categoryId) {
    final hash = categoryId.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    const icons = [
      Icons.label_outline,
      Icons.folder_outlined,
      Icons.bookmark_outline,
      Icons.star_outline,
      Icons.flag_outlined,
    ];
    return icons[hash % icons.length];
  }
}
