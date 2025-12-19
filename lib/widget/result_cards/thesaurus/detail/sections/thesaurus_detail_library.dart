import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../model/result.dart';
import '../../../../../service/apis.dart';

class ThesaurusDetailLibrary extends StatefulWidget {
  final ThesaurusResult result;

  const ThesaurusDetailLibrary({super.key, required this.result});

  @override
  State<ThesaurusDetailLibrary> createState() => _ThesaurusDetailLibraryState();
}

class _ThesaurusDetailLibraryState extends State<ThesaurusDetailLibrary> {
  bool loading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    _fetchLibrary();
  }

  Future<void> _fetchLibrary() async {
    final termId = widget.result.id;

    if (termId == null || termId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    // آدرس API از ApiUrls گرفته می‌شود
    final url = ApiUrls.resourcesForTerm(termId);

    try {
      final res = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        items = body["data"] ?? [];
      }

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (items.isEmpty) {
      return const Center(
        child: Text(
          "منبعی یافت نشد",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    int cardCount = 2;
    int crossAxisCount = 2;

    if (width > 1200) {
      cardCount = 6;
      crossAxisCount = 6;
    } else if (width > 800) {
      cardCount = 3;
      crossAxisCount = 3;
    }

    final cardItems = items.take(cardCount).toList();
    final listItems = items.skip(cardCount).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کارت‌ها
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cardItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, i) {
              final item = cardItems[i];
              final doc = item["doc"] ?? {};
              final title = doc["title"] ?? "";
              final pages = item["pages"] ?? "";
              final text = item["text"] ?? "";

              return _LibraryCard(
                title: title,
                pages: pages,
                text: text,
                colorScheme: Theme.of(context).colorScheme,
              );
            },
          ),

          const SizedBox(height: 28),

          // لیست زیر کارت‌ها
          ...listItems.map((item) {
            final doc = item["doc"] ?? {};
            final title = doc["title"] ?? "";
            final pages = item["pages"] ?? "";
            final text = item["text"] ?? "";

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) =>
                        _LibraryDetailDialog(title: title, pages: pages, text: text),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pages,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String pages;
  final String text;
  final ColorScheme colorScheme;

  const _LibraryCard({
    required this.title,
    required this.pages,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade400, width: 0.4),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) =>
                  _LibraryDetailDialog(title: title, pages: pages, text: text),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(
                pages,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryDetailDialog extends StatelessWidget {
  final String title;
  final String pages;
  final String text;

  const _LibraryDetailDialog({
    required this.title,
    required this.pages,
    required this.text,
  });

  String _clean(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = MediaQuery.of(context).size.width > 800 ? 150.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: 40),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cs.secondary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pages,
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      _clean(text),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        height: 1.5,
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