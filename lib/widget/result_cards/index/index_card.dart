import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'index_detail.dart';
import 'index_card_third_part.dart';
import 'package:go_router/go_router.dart';

class IndexCard extends StatelessWidget {
  final ThesaurusResult result;
  const IndexCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    final fromIndex = result.docDetails != null;
    final type = fromIndex ? result.bookType : result.type;

    return SizedBox(
      height: 280,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بخش اول: نمایه
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) =>
                            IndexDetailTitle(result: result),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 55,
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "نمایه: ",
                          style: TextStyle(
                              color: c.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: result.indexTitle,
                          style: TextStyle(
                              color: c.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                  ),
                ),

                Divider(color: Colors.grey.shade300, thickness: 1),

                // بخش دوم: اصطلاحات (فقط رشته)
                SizedBox(
                  height: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "اصطلاحات:",
                          style: TextStyle(
                            color: c.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: result.serviceTerms.map((t) {
                            final termId = t['id']?.toString();
                            final termTitle = t['title'] ?? '';
                            final termSlug = t['slug'] ?? '';

                            return InkWell(
                              onTap: () {
                                context.push(
                                  '/thesaurus/detail/$termId',
                                  extra: ThesaurusResult.fromJson({
                                    "id": termId,
                                    "title": termTitle,
                                    "slug": termSlug,
                                  }),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  border: Border.all(color: c.primary, width: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  termTitle,
                                  style: TextStyle(color: c.primary, fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(color: Colors.grey.shade300, thickness: 1),

                // بخش سوم: نوع
                IndexCardThirdPart(result: result, type: type),
              ],
            ),
          ),
        ),
      ),
    );
  }
}