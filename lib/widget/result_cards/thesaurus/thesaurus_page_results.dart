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
import '../../../widget/loading.dart';

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
  String? selectedDomainTitle;
  String? termDomain;

  int total = 0, currentPage = 0;
  bool loading = true, loadingDescription = true;

  int? activeDomainId;
  int? hoveredDomainId;

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

    if (activeDomainId != null && activeDomainId != 0) {
      final dom = domains.firstWhere(
        (x) => x['id'] == activeDomainId,
        orElse: () => {},
      );
      if (dom.isNotEmpty) selectedDomainTitle = dom['title'];
    }
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
      if (results.isNotEmpty) termDomain = results.first.domain;
    });
  }

  Future<void> _loadDescription() async {
    try {
      final s = await http.get(Uri.parse(ApiUrls.searchTerm(widget.query)));
      if (s.statusCode != 200) {
        setState(() => loadingDescription = false);
        return;
      }

      final first = (jsonDecode(s.body)['data'] as List?)?.first;
      if (first == null) {
        setState(() => loadingDescription = false);
        return;
      }

      final d = await http.get(Uri.parse(ApiUrls.lexiconForTerm(first['id'])));
      if (d.statusCode != 200) {
        setState(() => loadingDescription = false);
        return;
      }

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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ThesaurusDetailHeader(
                    searchQuery: widget.query,
                    selectedDomain: selectedDomainTitle,
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
                            final isHover = (hoveredDomainId == id);

                            Color? domainColor;
                            if (hex != null) {
                              domainColor = Color(
                                int.parse(hex.substring(1), radix: 16) + 0xFF000000,
                              );
                            }

                            final decoration = BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: isActive ? cs.surface : domainColor,
                              gradient: isActive ? null : (hex == null ? buildGradient(context).gradient : null),
                              border: Border.all(
                                color: isActive || isHover ? Colors.white : Colors.transparent,
                                width: 1.2,
                              ),
                              boxShadow: isHover
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                            );

                            return MouseRegion(
                              onEnter: (_) => setState(() => hoveredDomainId = id),
                              onExit: (_) => setState(() => hoveredDomainId = null),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    activeDomainId = id;
                                    selectedDomainTitle = title;
                                  });
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
                                          color: isActive ? cs.onSurface : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (isActive)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              activeDomainId = 0;
                                              selectedDomainTitle = null;
                                            });
                                            _loadPage(0);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(Icons.close, size: 18),
                                          ),
                                        ),
                                    ],
                                  ),
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
                              title: widget.query,
                              domainTitle: termDomain,
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

          // ⭐ لودینگ روی کل صفحه
          if (loading)
            const Positioned.fill(
              child: LoadingOverlay(),
            ),
        ],
      ),
    );
  }
}
