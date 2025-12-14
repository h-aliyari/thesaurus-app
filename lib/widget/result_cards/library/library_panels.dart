import 'package:flutter/material.dart';

class LibraryIndexesPanel extends StatelessWidget {
  final List<Map<String, dynamic>> indexes;
  const LibraryIndexesPanel({super.key, required this.indexes});

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
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: indexes.length,
              itemBuilder: (context, i) {
                final item = indexes[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    item['title'] ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    // TODO: ناوبری به صفحه دیتیل نمایه
                    debugPrint('Clicked index ${item['id']}');
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
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: terms.length,
              itemBuilder: (context, i) {
                final item = terms[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    item['title'] ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    debugPrint('Clicked term ${item['id']}');
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