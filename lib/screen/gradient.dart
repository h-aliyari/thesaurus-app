import 'package:flutter/material.dart';

/// تابع کمکی برای ساخت گرادیانت بر اساس حالت دارک/لایت
BoxDecoration buildGradient(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    gradient: LinearGradient(
      colors: isDark
          ? [const Color.fromARGB(255, 22, 64, 75), const Color.fromARGB(255, 18, 103, 66)]
          : [const Color(0xFF267285), const Color(0xFF25D68A)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );
}