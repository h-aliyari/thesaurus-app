import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../model/result.dart';
import '../../../service/apis.dart';
import '../../../service/thesaurus_api.dart';
import '../../../service/thesaurus_extra.dart';
import '../../../screen/gradient.dart';
import '../pagination.dart';
import 'detail/thesaurus_detail_header.dart';
import 'thesaurus_results_list.dart';
import 'thesaurus_description_box.dart';

class ThesaurusResultsPage extends StatefulWidget {
  final String query;
  final int? domainId;

  const ThesaurusResultsPage({
    super.key,
    required this.query,
    this.domainId,
  });

  @override
  State<ThesaurusResultsPage> createState() => _ThesaurusResultsPageState();
}

class _ThesaurusResultsPageState extends State<ThesaurusResultsPage> {
  List<ThesaurusResult> results = [];
  List<Map<String, dynamic>> domains = [];
  String? description;

  int total = 0, currentPage = 0;
  bool loading = true, loadingDescription = true;

  int? activeDomainId;

  @override
  void initState() {
    super.initState();
    activeDomainId = widget.domainId;
    _loadDomains();
    _loadPage(0);
    _loadDescription();
  }

  Future<void> _loadDomains() async {
    final d = await ThesaurusExtra.fetchDomains();
    setState(() => domains = d);
  }

  Future<void> _loadPage(int page) async {
    setState(() => loading = true);

    final res = await ThesaurusApi.fetchThesaurusPage(
      widget.query,
      page + 1,
      domainId: activeDomainId ?? 0,
    );

    setState(() {
      results = res.results;
      total = res.total;
      currentPage = page;
      loading = false;
    });
  }

  Future<void> _loadDescription() async {
    try {
      final s = await http.get(Uri.parse(ApiUrls.searchTerm(widget.query)));
      if (s.statusCode != 200) return setState(() => loadingDescription = false);

      final first = (jsonDecode(s.body)['data'] as List?)?.first;
      if (first == null) return setState(() => loadingDescription = false);

      final d = await http.get(Uri.parse(ApiUrls.lexiconForTerm(first['id'])));
      if (d.statusCode != 200) return setState(() => loadingDescription = false);

      description = jsonDecode(d.body)['data']?['description'] ?? '';
    } catch (_) {}
    setState(() => loadingDescription = false);
  }

  double _pad(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1200) return 80;
    if (w >= 900) return 50;
    if (w >= 600) return 30;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final pad = _pad(context);
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              ThesaurusDetailHeader(
                searchQuery: widget.query,
                selectedDomain: domains
                    .firstWhere(
                      (d) => d['id'] == activeDomainId,
                      orElse: () => {},
                    )
                    .putIfAbsent('title', () => null),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: cs.onBackground),
                      children: [
                        const TextSpan(text: 'نتایج جستجو برای : '),
                        TextSpan(
                          text: widget.query,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '   ($total مورد)',
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // دامنه‌ها با هایلایت و ضربدر
              if (domains.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: domains.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final d = domains[i];
                        final id = d["id"];
                        final title = d["title"] ?? "";
                        final hex = d["color"];

                        final isActive = (activeDomainId == id);

                        final cs = Theme.of(context).colorScheme;

                        // رنگ پس‌زمینهٔ صفحه (surface)
                        final bgColor = cs.surface;

                        // رنگ متن و ضربدر
                        final textColor = cs.onSurface;

                        // دامنه دارای hex → همان رنگ
                        Color? domainColor;
                        if (hex != null) {
                          domainColor = Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
                        }

                        // دامنه بدون hex → گرادیانت
                        final domainGradient = (hex == null) ? buildGradient(context).gradient : null;

                        // کادر دامنه فعال
                        final borderColor = cs.brightness == Brightness.light
                            ? Colors.black
                            : Colors.white;

                        final decoration = BoxDecoration(
                          borderRadius: BorderRadius.circular(5),

                          //  دامنه فعال → پس‌زمینه سفید + کادر
                          color: isActive ? bgColor : domainColor,
                          gradient: isActive ? null : domainGradient,

                          border: isActive
                              ? Border.all(color: borderColor, width: 1)
                              : null,
                        );

                        return GestureDetector(
                          onTap: () {
                            setState(() => activeDomainId = id);
                            _loadPage(0);
                          },
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: decoration,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: isActive ? textColor : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),

                                if (isActive)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => activeDomainId = 0);
                                      _loadPage(0);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (!isMobile)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ThesaurusDescriptionBox(
                          description: description,
                          loading: loadingDescription,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: ThesaurusResultsList(
                          results: results,
                          query: widget.query,
                          pad: _pad,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isMobile)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: ThesaurusResultsList(
                    results: results,
                    query: widget.query,
                    pad: _pad,
                  ),
                ),

              const SizedBox(height: 20),

              Center(
                child: Pagination(
                  currentPage: currentPage,
                  totalItems: total,
                  pageSize: 10,
                  onPageChanged: (p) => _loadPage(p),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}