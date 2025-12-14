import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'lexicon_card.dart';
import '../../../screen/translate.dart';
import '../pagination.dart';

class LexiconPageCards extends StatefulWidget {
  final List<ThesaurusResult> results;
  final String service;
  final int count;
  final String query;
  final int pageSize; // قابل تنظیم
  final int rowCount; // قابل تنظیم

  const LexiconPageCards({
    super.key,
    required this.results,
    required this.service,
    required this.count,
    required this.query,
    this.pageSize = 12,
    this.rowCount = 2,
  });

  @override
  State<LexiconPageCards> createState() => _LexiconPageCardsState();
}

class _LexiconPageCardsState extends State<LexiconPageCards> {
  int _currentPage = 0;

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
    if (widget.results.isEmpty) {
      return Center(
        child: Text(
          t(context, 'هیچ نتیجه‌ای یافت نشد', 'No results found.', 'لم يتم العثور على نتائج'),
        ),
      );
    }

    final start = _currentPage * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, widget.results.length);
    final pageItems = widget.results.sublist(start, end);

    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double horizontalPadding;

        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 4; // دسکتاپ
          horizontalPadding = 100;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 3; // تبلت
          horizontalPadding = 70;
        } else if (constraints.maxWidth >= 500) {
          crossAxisCount = 2; // موبایل متوسط
          horizontalPadding = 40;
        } else {
          crossAxisCount = 1; // موبایل کوچک
          horizontalPadding = 10;
        }

        return Column(
          children: [
            // هدر نتایج
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
                        TextSpan(text: t(context, "نتایج جستجو برای : ", 'Search results for:', 'نتائج البحث عن:')),
                        TextSpan(
                          text: " ${widget.query} ",
                          style: TextStyle(
                            fontSize: 20,
                            color: cs.secondary,
                          ),
                        ),
                        TextSpan(
                          text: " (${_toPersianNumber(widget.count)} ${t(context, 'مورد', 'item', 'عنصر')})",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox.shrink(),
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
                  crossAxisSpacing: 23,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 230,
                ),
                itemCount: pageItems.length,
                itemBuilder: (context, i) => LexiconCard(result: pageItems[i]),
              ),
            ),

            const SizedBox(height: 16),

            // Pagination
            Directionality(
              textDirection: TextDirection.ltr,
              child: Pagination(
                currentPage: _currentPage,
                totalItems: widget.count,
                pageSize: widget.pageSize,
                onPageChanged: (page) => setState(() => _currentPage = page),
              ),
            )
          ],
        );
      },
    );
  }
}
