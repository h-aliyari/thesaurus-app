import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'lexicon_datail.dart';

class LexiconCard extends StatelessWidget {
  final ThesaurusResult result;
  final double cardHeight;

  const LexiconCard({
    super.key,
    required this.result,
    this.cardHeight = 230,
  });

  /// پاکسازی متن از HTML و کاراکترهای اضافی
  String _cleanText(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString();
    final withoutTags = s.replaceAll(RegExp(r'<[^>]*>'), '');
    final normalized = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ct = Theme.of(context).cardTheme;

    final previewText = result.preview.isNotEmpty ? result.preview : (result.description ?? '');

    return SizedBox(
      height: cardHeight,
      child: Card(
        color: ct.color,
        elevation: ct.elevation ?? 2,
        margin: ct.margin,
        shadowColor: ct.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
            color: Color.fromARGB(255, 98, 97, 97),
            width: 0.3,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => LexiconDetail(result: result),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                /// عنوان
                SizedBox(
                  height: 48,
                  child: Text(
                    _cleanText(result.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: cs.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 8),

                /// توضیح / پیش‌نمایش
                Expanded(
                  child: Text(
                    _cleanText(previewText),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}