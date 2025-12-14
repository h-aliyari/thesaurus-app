import 'package:flutter/material.dart';
import '../../../model/result.dart';
import '../base_screen.dart';
import 'feature_block.dart';
import '../../../widget/result_cards/library/library_card.dart';
import '../../../service/thesaurus_api.dart';

Widget buildResourcesIntro(
  BuildContext context,
  String Function(String fa, String en) t,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FutureBuilder<List<ThesaurusResult>>(
        future: ThesaurusApi.fetchLatestDocs(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final latestResults = snapshot.data ?? [];

          if (latestResults.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t("هیچ منبع جدیدی یافت نشد", "No new resources found"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding;

              if (constraints.maxWidth >= 1000) {
                horizontalPadding = 110; // دسکتاپ
              } else if (constraints.maxWidth >= 700) {
                horizontalPadding = 70; // تبلت
              } else if (constraints.maxWidth >= 500) {
                horizontalPadding = 40; // موبایل متوسط
              } else {
                horizontalPadding = 16; // موبایل کوچک
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان سمت راست
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        t("جدیدترین منابع", "Latest Resources"),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 106, 126, 136),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // کارت‌ها
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: latestResults.length > 5 ? 5 : latestResults.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => SizedBox(
                          width: 250,
                          child: LibraryCard(result: latestResults[i]),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      const SizedBox(height: 24),

      const FullWidthWidget(
        child: ThesaurusFeatureBlock(),
      ),
    ],
  );
}
