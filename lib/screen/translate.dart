import 'package:flutter/material.dart';

/// تابع ترجمه با ورودی‌های متغیر (1 تا 3 رشته)
String t(BuildContext context, String text1, [String? text2, String? text3]) {
  final code = Localizations.localeOf(context).languageCode;

  switch (code) {
    case 'fa':
      return text1;
    case 'en':
      return text2 ?? text1;
    case 'ar':
      return text3 ?? text2 ?? text1;
    default:
      return text1;
  }
}