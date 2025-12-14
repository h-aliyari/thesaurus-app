import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../model/result.dart';
import '../../../screen/translate.dart';
import '../../provider/thesaurus_provider.dart';

import 'lexicon/lexicon_card.dart';
import 'thesaurus/thesaurus_card.dart';
import 'index/index_card.dart';
import 'library/library_card.dart';

class AllResultCards extends StatelessWidget {
  final Map<String, List<ThesaurusResult>> resultsByService;
  final Map<String, int> resultCounts;

  const AllResultCards({
    super.key,
    required this.resultsByService,
    required this.resultCounts,
  });

  @override
  Widget build(BuildContext context) {
    if (resultsByService.isEmpty) {
      return const SizedBox.shrink();
    }

    final order = ['اصطلاحنامه', 'فرهنگنامه', 'نمایه', 'کتابخانه'];

    final sortedEntries = resultsByService.entries.toList()
      ..sort((a, b) => order.indexOf(a.key).compareTo(order.indexOf(b.key)));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: sortedEntries.map((entry) {
          final service = entry.key;
          final results = entry.value;
          final count = resultCounts[service] ?? results.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;

              double cardWidth;
              double horizontalPadding;

              if (width >= 1000) {
                cardWidth = width / 4.5;
                horizontalPadding = 100;
              } else if (width >= 700) {
                cardWidth = width / 2.5;
                horizontalPadding = 70;
              } else if (width >= 500) {
                cardWidth = width / 2.2;
                horizontalPadding = 40;
              } else {
                cardWidth = width / 1.2;
                horizontalPadding = 10;
              }

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // هدر سرویس
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            final provider = context.read<ThesaurusProvider>();
                            final lastQuery = provider.lastQuery;

                            if (service == 'اصطلاحنامه') {
                              context.go('/thesaurus?query=$lastQuery');
                            } else if (service == 'فرهنگنامه') {
                              context.go('/lexicon?query=$lastQuery');
                            } else if (service == 'نمایه') {
                              context.go('/index?query=$lastQuery');
                            } else if (service == 'کتابخانه') {
                              context.go('/resources?query=$lastQuery');
                            }
                          },
                          child: Text(
                            t(context, 'مشاهده بیشتر', 'View more', 'عرض المزيد'),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),

                        Text(
                          '${t(context, 'نتیجه جستجو در', 'Search results in', 'نتيجة البحث في')} '
                          '$service ($count ${t(context, 'مورد', 'item', 'عنصر')})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // کارت‌ها
                    if (results.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: results.take(5).map((r) {
                            Widget card;

                            if (service == 'فرهنگنامه') {
                              card = LexiconCard(result: r);
                            } else if (service == 'نمایه') {
                              card = IndexCard(result: r);
                            } else if (service == 'کتابخانه') {
                              card = LibraryCard(result: r);
                            } else {
                              card = ThesaurusCard(result: r);
                            }

                            return Container(
                              width: cardWidth,
                              margin: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 15,
                                bottom: 60,
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: card,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}