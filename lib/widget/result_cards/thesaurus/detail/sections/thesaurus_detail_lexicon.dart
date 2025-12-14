import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../model/result.dart';
import '../../../../../service/apis.dart';

class ThesaurusDetailLexicon extends StatefulWidget {
  final ThesaurusResult result;

  const ThesaurusDetailLexicon({super.key, required this.result});

  @override
  State<ThesaurusDetailLexicon> createState() => _ThesaurusDetailLexiconState();
}

class _ThesaurusDetailLexiconState extends State<ThesaurusDetailLexicon> {
  bool loading = true;
  String? htmlText;

  @override
  void initState() {
    super.initState();
    _fetchLexicon();
  }

  Future<void> _fetchLexicon() async {
    final id = widget.result.id;
    if (id == null) {
      setState(() => loading = false);
      return;
    }

    final url = ApiUrls.lexiconForTerm(id);

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        htmlText = body["data"]?["description"] ?? "";
      }
    } catch (_) {}

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (htmlText == null || htmlText!.trim().isEmpty) {
      return const Center(
        child: Text(
          "مطلبی برای فرهنگنامه موجود نیست",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      );
    }

    final cleaned = _cleanHtml(htmlText!);
    final parts = _splitMainAndSources(cleaned);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // متن اصلی
              SelectableText(
                parts["main"]!,
                style: const TextStyle(fontSize: 15, height: 1.8),
              ),

              const SizedBox(height: 24),

              // منابع
              if (parts["sources"]!.trim().isNotEmpty)
                SelectableText(
                  parts["sources"]!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.8,
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
    final index = text.indexOf("1.");

    if (index == -1) {
      return {"main": text, "sources": ""};
    }

    final main = text.substring(0, index).trim();
    final sources = text.substring(index).trim();

    return {"main": main, "sources": sources};
  }

  /// پاک‌سازی HTML
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