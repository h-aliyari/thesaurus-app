import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'index_card.dart';
import '../../../screen/translate.dart';
import '../pagination.dart';

class IndexPageCards extends StatelessWidget {
  final List<ThesaurusResult> results;
  final String service;
  final int count;
  final String query;
  final int pageSize;
  final int currentPage;
  final Function(int) onPageChanged;

  const IndexPageCards({
    super.key,
    required this.results,
    required this.service,
    required this.count,
    required this.query,
    required this.pageSize,
    required this.currentPage,
    required this.onPageChanged,
  });

  String _toPersianNumber(int number) {
    const english = ['0','1','2','3','4','5','6','7','8','9'];
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    return number.toString().split('').map((e) {
      final i = english.indexOf(e);
      return i >= 0 ? persian[i] : e;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          t(context, 'هیچ نمایه‌ای یافت نشد', 'No indexes found.', 'لم يتم العثور على فهارس'),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double horizontalPadding;

        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 4;
          horizontalPadding = 100;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 3;
          horizontalPadding = 70;
        } else if (constraints.maxWidth >= 500) {
          crossAxisCount = 2;
          horizontalPadding = 40;
        } else {
          crossAxisCount = 1;
          horizontalPadding = 16;
        }

        return Column(
          children: [
            // هدر
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: cs.onBackground,
                      ),
                      children: [
                        TextSpan(text: t(context, "نمایه‌های یافت‌شده برای : ", 'Index results for:', 'نتائج الفهرسة عن:')),
                        TextSpan(
                          text: " $query ",
                          style: TextStyle(
                            fontSize: 20,
                            color: cs.secondary,
                          ),
                        ),
                        TextSpan(
                          text: " (${_toPersianNumber(count)} ${t(context, 'مورد', 'item', 'عنصر')})",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // کارت‌ها
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 280,
                ),
                itemCount: results.length,
                itemBuilder: (context, i) => IndexCard(result: results[i]),
              ),
            ),

            const SizedBox(height: 16),

            // صفحه‌بندی
            Directionality(
              textDirection: TextDirection.ltr,
              child: Pagination(
                currentPage: currentPage,
                totalItems: count,
                pageSize: pageSize,
                onPageChanged: onPageChanged,
              ),
            )
          ],
        );
      },
    );
  }
}