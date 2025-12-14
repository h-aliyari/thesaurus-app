import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/result.dart';
import '../../../screen/translate.dart';
import 'library_detail_header.dart';
import '../pagination.dart';
import '../../../provider/thesaurus_provider.dart';
import 'library_panels.dart';

class LibraryReadPage extends StatefulWidget {
  final ThesaurusResult result;
  final String searchQuery;

  const LibraryReadPage({
    super.key,
    required this.result,
    this.searchQuery = '',
  });

  @override
  State<LibraryReadPage> createState() => _LibraryReadPageState();
}

class _LibraryReadPageState extends State<LibraryReadPage> {
  int currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<ThesaurusProvider>(context, listen: false);
      final idStr = widget.result.id;
      if (idStr != null && idStr.trim().isNotEmpty) {
        final trimmed = idStr.trim();
        final idInt = int.tryParse(trimmed);

        if (idInt != null) {
          try {
            await provider.fetchDocWithContents(idInt);
          } catch (e) {
            try {
              await provider.fetchDocDetails(idInt);
              await provider.fetchDocContents(idInt);
            } catch (e2) {
              if (kDebugMode) debugPrint('DEBUG[Page] fetchDocDetails/Contents failed: $e2');
            }
          }

          // indexes & terms
          try {
            await provider.fetchDocIndexesTerms(idInt);
          } catch (e) {
            if (kDebugMode) debugPrint('DEBUG[Page] fetchDocIndexesTerms error: $e');
          }
        } else {
          try {
            await provider.fetchDocWithContents(trimmed);
          } catch (e) {
            try {
              await provider.fetchDocDetails(trimmed);
              await provider.fetchDocContents(trimmed);
            } catch (e2) {
              if (kDebugMode) debugPrint('DEBUG[Page] fetchDocDetails/Contents failed for string id: $e2');
            }
          }

          try {
            await provider.fetchDocIndexesTerms(trimmed);
          } catch (e) {
            if (kDebugMode) debugPrint('DEBUG[Page] fetchDocIndexesTerms error for string id: $e');
          }
        }
      }
    });
  }

  String _cleanText(String? text) {
    if (text == null) return '';
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[%+?{}]'), '')
        .trim();
  }

  String _getPageText(int page, List contents) {
    if (page < contents.length) {
      final item = contents[page];
      final raw = (item is Map)
          ? (item['RawTextContent'] ?? item['rawTextContent'] ?? item['raw_text_content'])
          : (item.rawTextContent ?? '');
      return _cleanText(raw?.toString());
    } else {
      return 'دسترسی ندارید';
    }
  }

  double _getBoxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 800;
    if (w >= 800) return 500;
    return double.infinity;
  }

  double _getBoxHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return h * 0.6;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThesaurusProvider>(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final totalPages = provider.currentDocPageCount
        ?? widget.result.pageCount
        ?? provider.docContents.length;

    Widget mainColumn() {
      return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.surface,
                foregroundColor: isDark ? Colors.white : Colors.black,
                side: BorderSide(color: isDark ? Colors.white : Colors.black),
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(t(context, 'بازگشت', 'Back', 'رجوع')),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: _getBoxWidth(context),
              height: _getBoxHeight(context),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.secondary.withOpacity(0.5)),
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.docContents.isEmpty
                      ? const Center(child: Text('محتوایی برای نمایش وجود ندارد'))
                      : SingleChildScrollView(
                          controller: _scrollController,
                          child: Text(
                            _getPageText(currentPage, provider.docContents),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onBackground,
                              height: 1.6,
                            ),
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Pagination(
              currentPage: currentPage,
              totalItems: totalPages,
              pageSize: 1,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                });
              },
            ),
          ),
        ],)
      );
    }

    Widget sideBar() {
      final indexes = provider.docPageIndexes;
      final terms = provider.docPageTerms;

      if (kDebugMode) {
        debugPrint('DEBUG[UI] sideBar indexes=${indexes.length} terms=${terms.length}');
      }

      return Column(
        children: [
          LibraryIndexesPanel(indexes: indexes),
          LibraryTermsPanel(terms: terms),
        ],
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            HeaderWidget(searchQuery: widget.searchQuery),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  if (isWide) {
                    return Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(flex: 0, child: mainColumn()),
                        const SizedBox(width: 16),
                        SizedBox(width: 300, child: sideBar()),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        mainColumn(),
                        const SizedBox(height: 20),
                        sideBar(),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}