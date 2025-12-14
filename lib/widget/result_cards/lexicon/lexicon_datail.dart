import 'package:flutter/material.dart';
import '../../../model/result.dart';

class LexiconDetail extends StatelessWidget {
  final ThesaurusResult result;

  const LexiconDetail({super.key, required this.result});

  String _stripHtmlTags(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(regex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalPadding = screenWidth > 800 ? 150 : 20;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
              child: GestureDetector(
                onTap: () {},
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          // تیتر
                          Text(
                            result.title,
                            style: TextStyle(
                              color: cs.secondary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          const SizedBox(height: 16),

                          // توضیحات فرهنگ‌نامه
                          if (result.encyclopediaDescription != null &&
                              result.encyclopediaDescription!.isNotEmpty)
                            Text(
                              _stripHtmlTags(result.encyclopediaDescription!),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                          const SizedBox(height: 16),

                          // ارجاع
                          if (result.reference != null)
                            Text(
                              result.reference!,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ضربدر
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.background.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: cs.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}