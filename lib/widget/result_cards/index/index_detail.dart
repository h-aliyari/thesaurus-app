import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'package:go_router/go_router.dart';

/// بخش اول: دیالوگ نمایه
class IndexDetailTitle extends StatelessWidget {
  final ThesaurusResult result;
  const IndexDetailTitle({super.key, required this.result});

  String _clean(String? text) =>
      text?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final pad = screenWidth > 800 ? 150.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 40),
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
                          Text(
                            result.indexTitle,
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (result.description?.isNotEmpty ?? false)
                            Text(
                              _clean(result.description),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
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

/// بخش دوم: اصطلاحات
class IndexDetailTerms extends StatelessWidget {
  final ThesaurusResult result;
  const IndexDetailTerms({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (result.terms.isEmpty) {
      return Center(child: Text("هیچ اصطلاحی یافت نشد"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("اصطلاحات مرتبط")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.terms.map((t) {
            return InkWell(
              onTap: () {
                context.push(
                  '/thesaurus/detail/$t',
                  extra: ThesaurusResult.fromJson({
                    "id": t,
                    "title": t,
                    "slug": t,
                  }),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.primary, width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(t, style: TextStyle(color: cs.primary, fontSize: 13)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}