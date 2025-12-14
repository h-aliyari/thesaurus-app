import 'package:flutter/material.dart';
import '../../../../model/result.dart';

class ThesaurusDetailTitle extends StatelessWidget {
  final ThesaurusResult result;
  final bool isDark;

  const ThesaurusDetailTitle({
    super.key,
    required this.result,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // سمت چپ وضعیت/مرجح
            if (result.status != null || result.pref != null)
              Text(
                '${result.status ?? ''} | ${result.pref ?? ''}',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            // سمت راست عنوان
            Text(
              result.title,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(height: 1, color: Colors.grey.shade400, width: double.infinity),
            if (result.domain != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 0.8),
                ),
                child: Text(
                  result.domain!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],)
    );
  }
}