import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'translate.dart';

class TopMenu extends StatelessWidget {
  const TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'fa': 'کتابخانه', 'en': 'Library', 'ar': 'المكتبة', 'path': '/resources'},
      {'fa': 'نمایه', 'en': 'Index', 'ar': 'الفهرس', 'path': '/index'},
      {'fa': 'فرهنگنامه', 'en': 'Lexicon', 'ar': 'المعجم', 'path': '/lexicon'},
      {'fa': 'اصطلاحنامه', 'en': 'Thesaurus', 'ar': 'الموسوعه', 'path': '/thesaurus'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(menuItems.length * 2 - 1, (i) {
              if (i.isOdd) {
                // خط عمودی کوتاه وسط متن‌ها
                return Container(
                  width: 1.5,
                  height: 18,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                );
              } else {
                final item = menuItems[i ~/ 2];
                return TextButton(
                  onPressed: () => context.push(item['path']!),
                  child: Text(
                    t(context, item['fa']!, item['en']!, item['ar']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'IranSans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
