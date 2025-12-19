import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/result.dart';
import '../../../provider/thesaurus_provider.dart';
import 'library_card.dart';
import 'advanced_search_box.dart';
import '../pagination.dart';

class LibraryPageCards extends StatefulWidget {
  final List<ThesaurusResult> results;
  final int pageSize;
  final String searchQuery;

  const LibraryPageCards({
    super.key,
    required this.results,
    this.pageSize = 12,
    required this.searchQuery,
  });

  @override
  State<LibraryPageCards> createState() => _LibraryPageCardsState();
}

class _LibraryPageCardsState extends State<LibraryPageCards> {
  int _currentPage = 0;

  String _toPersianNumber(int number) {
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    return number.toString().split('').map((e) {
      final i = en.indexOf(e);
      return i >= 0 ? fa[i] : e;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThesaurusProvider>(context);
    final cs = Theme.of(context).colorScheme;

    // نتایج کامل از Provider
    final List<ThesaurusResult> results = provider.getResults('کتابخانه');

    // تعداد واقعی نتایج
    final int total = provider.getCount('کتابخانه');

    // صفحه‌بندی درست
    final pageItems = results;

    const cardSpacing = 23.0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 500
                ? 2
                : 1;

        double horizontalPadding = constraints.maxWidth >= 1000
            ? 130
            : constraints.maxWidth >= 700
                ? 30
                : 16;

        // هدر
        Widget header = Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: cs.onSurface),
                children: [
                  const TextSpan(text: 'نتایج جستجو برای : '),
                  TextSpan(
                    text: '"${provider.lastQuery.isNotEmpty ? provider.lastQuery : widget.searchQuery}"',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 64, 147, 67),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '  (${_toPersianNumber(total)} مورد)',
                    style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        );

        // کارت‌ها
        Widget cards = results.isNotEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: cardSpacing,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 230,
                    ),
                    itemCount: pageItems.length,
                    itemBuilder: (context, i) => LibraryCard(result: pageItems[i]),
                  ),
                ),
              )
            : const Center(child: Text('هیچ نتیجه‌ای یافت نشد'));

        // جعبه سرچ پیشرفته
        Widget searchBox = SizedBox(
          width: 280,
          child: AdvancedSearchBox(
            initialTitle: provider.lastTitle,
            initialPublisher: provider.lastPublisher,
            initialAuthor: provider.lastAuthor,
            initialSubject: provider.lastSubject,
            initialType: provider.lastType,
            onSearch: ({
              required String title,
              required String publisher,
              required String author,
              required String subject,
              required String type,
            }) async {
              await provider.searchAdvanced(
                title: title,
                publisher: publisher,
                author: author,
                subject: subject,
                type: type,
              );
              setState(() {
                _currentPage = 0;
              });
            },
          ),
        );

        return Column(
          children: [
            header,
            const SizedBox(height: 20),

            constraints.maxWidth >= 700
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: cards),
                        const SizedBox(width: cardSpacing),
                        searchBox,
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(16), child: searchBox),
                      cards,
                    ],
                  ),

            const SizedBox(height: 16),

            // صفحه‌بندی
            if (results.isNotEmpty)
              Pagination(
                currentPage: _currentPage,
                totalItems: total,
                pageSize: widget.pageSize,
                onPageChanged: (page) async {
                  await provider.searchLibraryPage(provider.lastQuery, page + 1);
                  setState(() => _currentPage = page);
                },
              ),
          ],
        );
      },)
    );
  }
}