import 'package:flutter/material.dart';
import '../base_screen.dart';
import '../../../service/thesaurus_api.dart';
import '../intros/index_intro.dart';
import '../translate.dart';
import '../../widget/result_cards/index/index_page_results.dart';
import '../../../service/apis.dart';
import '../../../model/result.dart';

class IndexScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const IndexScreen({super.key, this.initialSearchQuery});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _currentPage = 0;
  List<ThesaurusResult> _pageResults = [];
  int _total = 0;
  bool _loading = false;

  Future<void> loadPage(int page) async {
    setState(() => _loading = true);

    final result = await ThesaurusApi.fetchPage(
      widget.initialSearchQuery ?? '',
      ApiUrls.indexPaged,
      page + 1,
    );

    setState(() {
      _currentPage = page;
      _pageResults = result.results;
      _total = result.total;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      loadPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: t(context, 'نمایه', 'Index', 'الفهرس'),
      subtitle: t(
        context,
        'گنجینه نمایه های علوم اسلامی',
        'Treasury of Islamic Science Indexes',
        'فهارس خزانة العلوم الإسلامية',
      ),
      showCategoryDropdown: false,
      categoriesBuilder: (ctx) => [],
      defaultCategory: null,
      showIntro: true,
      customIntro: buildIndexIntro((fa, en) {
        final locale = Localizations.localeOf(context).languageCode;
        return locale == 'fa' ? fa : en;
      }),

      // صفحه ۱ را لود می‌کند
      onSearch: (context, query, selectedCategory) {
        setState(() {
          _currentPage = 0;
        });
        loadPage(0);
      },

      isHome: false,

      pageResults: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexPageCards(
              results: _pageResults,
              service: 'نمایه',
              count: _total,
              query: widget.initialSearchQuery ?? '',
              pageSize: 12,
              currentPage: _currentPage, 
              onPageChanged: (page) => loadPage(page),
            ),
    );
  }
}