import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../model/result.dart';
import '../../../../service/apis.dart';

import 'thesaurus_detail_header.dart';
import 'thesaurus_detail_title.dart';
import 'thesaurus_options_bar.dart';

import 'sections/thesaurus_detail_index.dart';
import 'sections/thesaurus_detail_library.dart';
import 'sections/thesaurus_detail_lexicon.dart';
import 'sections/thesaurus_detail_tree.dart';
import 'sections/thesaurus_detail_relation.dart';

class ThesaurusDetailPage extends StatefulWidget {
  final ThesaurusResult? result;
  final String? slug;
  final String searchQuery;

  const ThesaurusDetailPage({
    super.key,
    this.result,
    this.slug,
    this.searchQuery = '',
  });

  @override
  State<ThesaurusDetailPage> createState() => _ThesaurusDetailPageState();
}

class _ThesaurusDetailPageState extends State<ThesaurusDetailPage> {
  ThesaurusResult? data;
  bool loading = true;

  String activeLabel = 'رابطه';

  @override
  void initState() {
    super.initState();

    if (widget.result != null &&
        (widget.result!.relationsCount != null ||
         widget.result!.indexesCount != null)) {
      data = widget.result;
      loading = false;
    } else {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    final slug = widget.slug ??
        widget.result?.slug ??
        widget.result?.id?.toString();

    if (slug == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final url = "${ApiUrls.thesaurus}/$slug";
      final res = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          data = ThesaurusResult.fromJson(body['data']);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Widget _buildSection() {
    if (data == null) return const SizedBox();

    switch (activeLabel) {
      case 'نمایه':
        return ThesaurusDetailIndex(termId: data!.id!);
      case 'منابع':
        return ThesaurusDetailLibrary(result: data!);
      case 'فرهنگنامه':
        return ThesaurusDetailLexicon(result: data!);
      case 'درختواره':
        return ThesaurusDetailTree(result: data!);
      case 'رابطه':
      default:
        return ThesaurusDetailRelation(result: data!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("خطا در دریافت اطلاعات")),
      );
    }

    final r = data!;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ThesaurusDetailHeader(searchQuery: widget.searchQuery),

            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThesaurusDetailTitle(
                      result: r,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),

                    const SizedBox(height: 24),

                    ThesaurusOptionsBar(
                      activeLabel: activeLabel,
                      onSelect: (label) => setState(() => activeLabel = label),
                      indexCount: r.indexesCount ?? 0,
                      relationCount: r.relationsCount ?? 0,
                    ),

                    const SizedBox(height: 24),

                    _buildSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),)
    );
  }
}