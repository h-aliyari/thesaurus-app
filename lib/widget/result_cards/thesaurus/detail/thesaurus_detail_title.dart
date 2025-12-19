import 'package:flutter/material.dart';
import '../../../../model/result.dart';
import '../../../../service/apis.dart';

class ThesaurusDetailTitle extends StatelessWidget {
  final ThesaurusResult result;
  final bool isDark;
  final List<Map<String, dynamic>> attachments;

  const ThesaurusDetailTitle({
    super.key,
    required this.result,
    required this.isDark,
    required this.attachments,
  });

  @override
  Widget build(BuildContext context) {
    // ⭐ استخراج note و description
    final note = (result.note != null && result.note!.trim().isNotEmpty)
        ? "ی.د : ${result.note!}"
        : null;

    final desc = (result.description != null && result.description!.trim().isNotEmpty)
        ? "ی.د : ${result.description!}"
        : null;

    // ⭐ لیست نهایی توضیحات
    final List<String> extraTexts = [];
    if (note != null) extraTexts.add(note);
    if (desc != null) extraTexts.add(desc);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // -------------------------
          //  عنوان + وضعیت/مرجح
          // -------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (result.status != null || result.pref != null)
                Text(
                  '${result.status ?? ''} | ${result.pref ?? ''}',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),

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

          // -------------------------
          //  دامنه + توضیحات + ضمیمه‌ها
          // -------------------------
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                height: 1,
                color: Colors.grey.shade400,
                width: double.infinity,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ⭐ دامنه
                    if (result.domain != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 0.8),
                        ),
                        child: Text(
                          result.domain!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    // فاصله بین دامنه و توضیحات
                    if (extraTexts.isNotEmpty)
                      const SizedBox(height: 6),

                    // ⭐ توضیحات (note و description)
                    if (extraTexts.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF111111)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 0.6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: extraTexts
                              .map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    t,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontSize: 12,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    // -------------------------
                    //  ضمیمه‌ها
                    // -------------------------
                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      const Text(
                        "ضمیمه‌ها:",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: attachments.map((att) {
                          final title = att["doc"]?["title"] ?? "";
                          final img = att["text"] ?? "";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    "${ApiUrls.baseUrl}$img",
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
