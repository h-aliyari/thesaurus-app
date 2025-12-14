import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../base_screen.dart';
import '../../../provider/thesaurus_provider.dart';
import '../../../service/thesaurus_api.dart';
import '../intros/resources_intro.dart';
import '../translate.dart';
import '../../widget/result_cards/library/library_page_results.dart';

class ResourcesScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const ResourcesScreen({super.key, this.initialSearchQuery});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleQuery(initial: true));
  }

  @override
  void didUpdateWidget(covariant ResourcesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldQ = (oldWidget.initialSearchQuery ?? '').trim();
    final newQ = (widget.initialSearchQuery ?? '').trim();

    if (oldQ != newQ) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleQuery(initial: false));
    }
  }

  void _handleQuery({required bool initial}) {
    final provider = Provider.of<ThesaurusProvider>(context, listen: false);

    String query = widget.initialSearchQuery?.trim() ?? '';
    if (query.isEmpty) {
      query = (Uri.base.queryParameters['query'] ?? '').trim();
    }

    if (query.isNotEmpty) {
      provider.clear();
      provider.searchSingle(ThesaurusService.resources, 'کتابخانه', query);
    } else {
      provider.fetchLatestDocs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: t(context, 'کتابخانه', 'Library', 'المکتبه'),
      subtitle: t(
        context,
        'گنجینه منابع علوم اسلامی',
        'Treasure trove of Islamic science resources',
        'كنز من موارد العلوم الإسلامية',
      ),
      showCategoryDropdown: false,
      categoriesBuilder: (ctx) => [],
      defaultCategory: null,
      showIntro: true,
      customIntro: buildResourcesIntro(context, (fa, en) {
        final locale = Localizations.localeOf(context).languageCode;
        return locale == 'fa' ? fa : en;
      }),

      onSearch: (context, query, selectedCategory) {
        final provider = context.read<ThesaurusProvider>();
        provider.clear();
        provider.searchSingle(
          ThesaurusService.resources,
          'کتابخانه',
          query,
        );
      },

      isHome: false,

      pageResults: Consumer<ThesaurusProvider>(
        builder: (ctx, provider, _) {
          final results = provider.getResults('کتابخانه');
          final searchQuery = provider.lastQuery;

          return LibraryPageCards(
            results: results,
            searchQuery: searchQuery,
          );
        },
      ),
    );
  }
}