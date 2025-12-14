import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../model/result.dart';
import '../../../../../service/apis.dart';
import '../../../../result_cards/index/index_card.dart';
import '../../../../result_cards/pagination.dart';

class ThesaurusDetailIndex extends StatefulWidget {
  final String termId;

  const ThesaurusDetailIndex({super.key, required this.termId});

  @override
  State<ThesaurusDetailIndex> createState() => _ThesaurusDetailIndexState();
}

class _ThesaurusDetailIndexState extends State<ThesaurusDetailIndex> {
  List<ThesaurusResult> indexes = [];
  bool loading = true;

  int currentPage = 0;
  final int pageSize = 12;

  @override
  void initState() {
    super.initState();
    _fetchIndexes();
  }

  Future<void> _fetchIndexes() async {
    setState(() => loading = true);

    List<ThesaurusResult> all = [];
    int page = 1;
    int totalPages = 1;

    while (true) {
      final url = ApiUrls.indexForTermPaged(widget.termId, page);
      print("✅ FETCH URL = $url");

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) break;

      final body = jsonDecode(res.body);

      if (page == 1) {
        totalPages = body["meta"]?["pagination"]?["total_pages"] ?? 1;
        print("✅ totalPages = $totalPages");
      }

      final List<dynamic> data = body["data"] ?? [];

      all.addAll(
        data.whereType<Map<String, dynamic>>()
            .map((e) => ThesaurusResult.fromJson(e))
      );

      if (page >= totalPages) break;
      page++;
    }

    indexes = all;

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (indexes.isEmpty) {
      return const Center(
        child: Text(
          "نمایه‌ای موجود نیست",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    final start = currentPage * pageSize;
    final end = (start + pageSize).clamp(0, indexes.length);
    final pageItems = indexes.sublist(start, end);

    return Directionality(
      textDirection: TextDirection.rtl,
        child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          double horizontalPadding;

          if (constraints.maxWidth >= 1000) {
            crossAxisCount = 4;
            horizontalPadding = 100;
          } else if (constraints.maxWidth >= 700) {
            crossAxisCount = 3;
            horizontalPadding = 70;
          } else if (constraints.maxWidth >= 500) {
            crossAxisCount = 2;
            horizontalPadding = 40;
          } else {
            crossAxisCount = 1;
            horizontalPadding = 16;
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 280,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, i) => IndexCard(result: pageItems[i]),
                ),
              ),

              const SizedBox(height: 16),

              Directionality(
              textDirection: TextDirection.ltr,
              child: Pagination(
                currentPage: currentPage,
                totalItems: indexes.length,
                pageSize: pageSize,
                onPageChanged: (page) {
                  setState(() => currentPage = page);
                },
              ),)
            ],
          );
        },
      )
    );
  }
}