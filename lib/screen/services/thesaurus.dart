import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base_screen.dart';
import '../../provider/thesaurus_provider.dart';
import '../intros/thesaurus_intro.dart';
import '../translate.dart';
import '../../widget/result_cards/thesaurus/thesaurus_page_results.dart';
import '../../../service/thesaurus_extra.dart';

class ThesaurusScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final int? initialDomain;

  const ThesaurusScreen({super.key, this.initialSearchQuery, this.initialDomain});

  @override
  State<ThesaurusScreen> createState() => _ThesaurusScreenState();
}

class _ThesaurusScreenState extends State<ThesaurusScreen> {
  List<Map<String, dynamic>> domains = [];

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  Future<void> _loadDomains() async {
    final result = await ThesaurusExtra.fetchDomains();
    if (!mounted) return;
    setState(() => domains = result);
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = [
      t(context, 'دامنه', 'Domain', 'النطاق'),
      ...domains.map((d) => d['title']?.toString() ?? ''),
    ];

    return BaseScreen(
      title: t(context, 'اصطلاحنامه', 'Thesaurus', 'الموسوعه'),
      subtitle: t(context, 'گنجینه اصطلاحات علوم اسلامی',
          'Treasury of Islamic Sciences Terms',
          'مصطلحات خزانة العلوم الإسلامية'),
      showCategoryDropdown: true,
      categoriesBuilder: (ctx) => categoryList,
      defaultCategory: t(context, 'دامنه', 'Domain', 'النطاق'),
      showIntro: true,
      customIntro: buildThesaurusIntro(context, (fa, en) {
        final locale = Localizations.localeOf(context).languageCode;
        return locale == 'fa' ? fa : en;
      }),
      onSearch: (context, query, selectedCategory) async {
        final provider = context.read<ThesaurusProvider>();
        provider.clear();

        if (domains.isEmpty) {
          await _loadDomains();
        }

        if (selectedCategory == t(context, 'دامنه', 'Domain', 'النطاق')) {
          await provider.searchAllDomains(query);
        } else {
          final domain = domains.firstWhere(
            (d) {
              final t1 = (d['title'] ?? '').toString().trim().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
              final t2 = selectedCategory.trim().replaceAll('ي', 'ی').replaceAll('ك', 'ک');
              return t1 == t2;
            },
            orElse: () => <String, dynamic>{},
          );

          if (domain.isNotEmpty) {
            await provider.searchDomain(query, domain['id']);
          } else {
          }
        }
      },

      isHome: false,
      pageResults: Consumer<ThesaurusProvider>(
        builder: (ctx, provider, _) {
          final results = provider.byService['اصطلاحنامه'] ?? [];
          if (results.isEmpty) {
            return const SizedBox.shrink();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => ThesaurusResultsPage(
                  query: provider.lastQuery,
                  domainId: provider.lastDomainId,
                ),
              ),
            );
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}