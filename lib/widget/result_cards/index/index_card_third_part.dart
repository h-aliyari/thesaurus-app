import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'index_detail_third_part.dart';

class IndexCardThirdPart extends StatelessWidget {
  final ThesaurusResult result;
  final String? type;
  const IndexCardThirdPart({super.key, required this.result, this.type});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Tooltip(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.primary, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      richMessage: TextSpan(children: _buildBookTooltipSpans(c)),

      child: Builder(
        builder: (ctx) {
          return InkWell(
            onTap: () {
              Navigator.of(ctx, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => IndexDetailBook(result: result),
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 45,
              child: Row(
                children: [
                  Text(
                    "${type ?? ''}: ",
                    style: TextStyle(
                      color: c.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _bookLine(result),
                      style: TextStyle(color: c.primary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<InlineSpan> _buildBookTooltipSpans(ColorScheme c) {
    final spans = <InlineSpan>[];

    void addItem(String type, String title) {
      if (type.trim().isEmpty && title.trim().isEmpty) return;
      spans.addAll([
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
          ),
        ),
        TextSpan(
          text: type.isNotEmpty ? "$type: " : "",
          style: TextStyle(
            color: c.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: title,
          style: TextStyle(color: c.onSurface, fontSize: 13),
        ),
        const TextSpan(text: "\n"),
      ]);
    }

    addItem('عنوان', result.bookTitle ?? result.title);
    if (result.bookAuthor != null) addItem('نویسنده', result.bookAuthor!);
    if (result.bookPublisher != null) addItem('ناشر', result.bookPublisher!);
    if (result.bookPublishDate != null) addItem('تاریخ انتشار', result.bookPublishDate!);
    if (result.bookDescription != null) addItem('توضیحات', result.bookDescription!);

    for (final rel in result.bookRelations) {
      if (rel is Map) {
        final type = (rel['type']?['Title'] ?? rel['type']?['title'] ?? '').toString();
        final value = (rel['Value'] ?? '').toString();
        if (type.trim().isNotEmpty || value.trim().isNotEmpty) {
          addItem(type, value);
        }
      }
    }

    if (spans.isNotEmpty && (spans.last as TextSpan).text == "\n") {
      spans.removeLast();
    }

    return spans;
  }

  String _bookLine(ThesaurusResult r) {
    final v = r.volume, f = r.from, t = r.to;
    final meta = [
      if (v?.isNotEmpty ?? false) "جلد $v",
      if (f?.isNotEmpty ?? false)
        (t != null && t.isNotEmpty && t != f ? "صفحات $f–$t" : "صفحه $f")
    ].join("، ");
    return r.book != null && meta.isNotEmpty
        ? "${r.book} ($meta)"
        : (r.book ?? "");
  }
}