import 'package:flutter/material.dart';

/// Colors, card style and small formatting helpers shared by every
/// driver screen. These are the values from the original driver screens.
class DriverTheme {
  /// Main blue (home, history, buttons).
  static const Color primaryBlue = Color(0xFF1565C0);

  /// Dark blue (map header, profile header).
  static const Color deepBlue = Color(0xFF0B3D78);

  static const Color background = Color(0xFFF7F9FC);
  static const Color divider = Color(0xFFE8E8E8);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);

  static const Color success = Color(0xFF2E9E4F);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE53935);

  /// The white rounded card with a soft shadow used across the app.
  static BoxDecoration cardDecoration({double radius = 18}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Formatting
  // --------------------------------------------------------------------------

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// 18 August 2026
  static String formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// 18 Aug
  static String formatShortDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1].substring(0, 3)}';
  }
}