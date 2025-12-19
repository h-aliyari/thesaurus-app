import 'package:flutter/material.dart';

class ThesaurusDescriptionBox extends StatefulWidget {
  final String? description;
  final bool loading;
  final String? domainTitle;
  final String? title;

  /// مقدار سقف ارتفاع (قابل تنظیم)
  final double maxHeight;

  const ThesaurusDescriptionBox({
    super.key,
    required this.description,
    required this.loading,
    required this.title,
    required this.domainTitle,
    this.maxHeight = 1100,
  });

  @override
  State<ThesaurusDescriptionBox> createState() => _ThesaurusDescriptionBoxState();
}

class _ThesaurusDescriptionBoxState extends State<ThesaurusDescriptionBox> {
  int rating = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!widget.loading && (widget.description == null || widget.description!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final cleaned = widget.description == null ? '' : _cleanHtml(widget.description!);
    final parts = _splitMainAndSources(cleaned);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cs.primary.withOpacity(0.5), width: 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: widget.loading
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -------------------------
                  // عنوان اصطلاح
                  // -------------------------
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B8F4A),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // -------------------------
                  // ستاره‌ها
                  // -------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final index = i + 1;
                      final isFilled = index <= rating;

                      return GestureDetector(
                        onTap: () => setState(() => rating = index),
                        child: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          size: 28,
                          color: isFilled ? const Color.fromARGB(255, 255, 162, 22) : Colors.grey,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------
                  // دامنه
                  // -------------------------
                  if (widget.domainTitle != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 0.8),
                        ),
                        child: Text(
                          widget.domainTitle!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // -------------------------
                  // متن + منابع با اسکرول و سقف ارتفاع
                  // -------------------------
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.maxHeight, // ⭐ سقف ارتفاع
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // متن اصلی
                          Text(
                            parts['main']!,
                            style: const TextStyle(fontSize: 14, height: 1.7),
                          ),

                          if (parts['sources']!.trim().isNotEmpty)
                            const SizedBox(height: 12),

                          // منابع
                          if (parts['sources']!.trim().isNotEmpty)
                            Text(
                              parts['sources']!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.7,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// جدا کردن متن اصلی و منابع
  Map<String, String> _splitMainAndSources(String text) {
    final index = text.indexOf('1.');

    if (index == -1) {
      return {
        'main': text,
        'sources': '',
      };
    }

    final main = text.substring(0, index).trim();
    final sources = text.substring(index).trim();

    return {
      'main': main,
      'sources': sources,
    };
  }

  String _cleanHtml(String html) {
    String text = html;

    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');

    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&zwnj;', '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    text = text.split('\n').map((e) => e.trim()).join('\n');

    return text.trim();
  }
}
