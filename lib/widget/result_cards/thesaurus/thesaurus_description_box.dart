import 'package:flutter/material.dart';

class ThesaurusDescriptionBox extends StatelessWidget {
  final String? description;
  final bool loading;

  const ThesaurusDescriptionBox({
    super.key,
    required this.description,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!loading && (description == null || description!.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final cleaned = description == null ? '' : _cleanHtml(description!);
    final parts = _splitMainAndSources(cleaned);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: cs.primary.withOpacity(0.5), width: 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
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