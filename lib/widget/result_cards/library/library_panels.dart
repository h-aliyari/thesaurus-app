import 'package:flutter/material.dart';

class LibraryIndexesPanel extends StatelessWidget {
  final List<Map<String, dynamic>> indexes;
  const LibraryIndexesPanel({super.key, required this.indexes});

  String _extractTitle(Map<String, dynamic> item) {
    return item['title'] ??
           item['Title'] ??
           item['name'] ??
           item['Name'] ??
           item['value'] ??
           '';
  }

  String _extractId(Map<String, dynamic> item) {
    return item['id']?.toString() ??
           item['Id']?.toString() ??
           item['TermId']?.toString() ??
           item['DocId']?.toString() ??
           '';
  }

  @override
  Widget build(BuildContext context) {
    if (indexes.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: cs.secondary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // عنوان کادر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerRight,
            child: Text(
              'نمایه‌های صفحه',
              style: textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(height: 1, color: cs.secondary.withOpacity(0.4)),

          // لیست
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: indexes.length,
              itemBuilder: (context, i) {
                final item = indexes[i];
                final title = _extractTitle(item);
                final id = _extractId(item);

                return ListTile(
                  dense: true,
                  title: Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    debugPrint('Clicked index $id');
                    // TODO: ناوبری به دیتیل نمایه
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryTermsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> terms;
  const LibraryTermsPanel({super.key, required this.terms});

  String _extractTitle(Map<String, dynamic> item) {
    return item['title'] ??
           item['Title'] ??
           item['name'] ??
           item['Name'] ??
           item['value'] ??
           '';
  }

  String _extractId(Map<String, dynamic> item) {
    return item['id']?.toString() ??
           item['Id']?.toString() ??
           item['TermId']?.toString() ??
           item['DocId']?.toString() ??
           '';
  }

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: cs.secondary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // عنوان کادر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerRight,
            child: Text(
              'اصطلاحات صفحه',
              style: textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Divider(height: 1, color: cs.secondary.withOpacity(0.4)),

          // لیست
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: terms.length,
              itemBuilder: (context, i) {
                final item = terms[i];
                final title = _extractTitle(item);
                final id = _extractId(item);

                return ListTile(
                  dense: true,
                  title: Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    debugPrint('Clicked term $id');
                    // TODO: ناوبری به دیتیل اصطلاح
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
