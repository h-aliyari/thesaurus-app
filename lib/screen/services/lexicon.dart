import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../base_screen.dart';
import '../../provider/thesaurus_provider.dart';
import '../../service/thesaurus_api.dart';
import '../intros/lexicon_intro.dart';
import '../translate.dart';
import '../../widget/result_cards/lexicon/lexicon_page_results.dart';

class LexiconScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const LexiconScreen({super.key, this.initialSearchQuery});

  @override
  State<LexiconScreen> createState() => _LexiconScreenState();
}

class _LexiconScreenState extends State<LexiconScreen> {
  bool _didSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didSearch &&
          widget.initialSearchQuery != null &&
          widget.initialSearchQuery!.isNotEmpty) {
        _didSearch = true;
        final provider = context.read<ThesaurusProvider>();
        provider.searchSingle(
          ThesaurusService.lexicon,
          'فرهنگنامه',
          widget.initialSearchQuery!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: t(context, 'فرهنگنامه', 'Lexicon', 'المعجم'),
      subtitle: t(
        context,
        'گنجینه فرهنگنامه های علوم اسلامی',
        'Treasure trove of Islamic sciences dictionaries',
        'كنز من معاجم العلوم الإسلامية',
      ),
      showCategoryDropdown: false,
      categoriesBuilder: (_) => [],
      defaultCategory: null,
      showIntro: true,
      customIntro: buildLexiconIntro((fa, en) {
        final locale = Localizations.localeOf(context).languageCode;
        return locale == 'fa' ? fa : en;
      }),
      onSearch: (context, query, selectedCategory) async {
        final provider = context.read<ThesaurusProvider>();
        await provider.searchSingle(
          ThesaurusService.lexicon,
          'فرهنگنامه',
          query,
        );
      },
      isHome: false,
      pageResults: Consumer<ThesaurusProvider>(
        builder: (ctx, provider, _) {
          final results = provider.byService['فرهنگنامه'] ?? [];
          final count = provider.resultCounts['فرهنگنامه'] ?? results.length;

          return LexiconPageCards(
            results: results,
            service: 'فرهنگنامه',
            count: count,
            query: provider.lastQuery,
          );
        },
      ),
    );
  }
}
