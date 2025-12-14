import 'package:flutter/material.dart';
import '../../../../model/result.dart';
import '../detail/thesaurus_detail.dart';

class ThesaurusGraphNative extends StatelessWidget {
  final ThesaurusResult result;
  final Map<String, List<dynamic>> relations;
  final Map<String, Color> relationColors;

  const ThesaurusGraphNative({
    super.key,
    required this.result,
    required this.relations,
    required this.relationColors,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    //  نود مرکزی
    children.add(
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThesaurusDetailPage(
                slug: result.slug ?? result.id.toString(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            result.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // نودهای روابط
    relations.forEach((code, list) {
      for (var item in list) {
        final term = item['term'] ?? {};
        final title = (term['title'] ?? '').toString();
        if (title.isEmpty) continue;

        children.add(const SizedBox(height: 12));

        children.add(
          InkWell(
            onTap: () {
              final slug = term['slug'] ?? term['id'].toString();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ThesaurusDetailPage(
                    slug: slug,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    });

    // کادر گراف
    return Container(
      width: 420,
      height: 420,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
