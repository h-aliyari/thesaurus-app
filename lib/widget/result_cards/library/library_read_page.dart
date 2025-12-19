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
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final p = Provider.of<ThesaurusProvider>(context, listen: false);

      final id = widget.result.id?.trim();
      if (id == null || id.isEmpty) return;

      final idInt = int.tryParse(id);

      // 1) گرفتن محتوا
      try {
        await p.fetchDocWithContents(idInt ?? id);
      } catch (_) {
        try {
          await p.fetchDocContents(idInt ?? id);
        } catch (_) {}
      }

      // 2) گرفتن page_count
      try {
        await p.fetchDocDetails(idInt ?? id);
      } catch (_) {}

      // 3) گرفتن کادرهای صفحه اول
      await _loadSidePanelsForPage(0);

      setState(() {});
    });
  }

  String _clean(String? t) =>
      t?.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'[%+?{}]'), '').trim() ?? '';

  String? _extractImg(String html) {
    final m = RegExp(r'src="([^"]+)"').firstMatch(html);
    if (m == null) return null;
    var src = m.group(1)?.trim();
    // اگر رشته با http شروع نشه، دامنه رو اضافه کن
    if (src != null && !src.startsWith('http')) {
      src = "https://file.isca.ac.ir$src";
    }
    return src;
  }

  /// ساخت ویجت برای یک آیتم از docContents
  Widget _buildContentItem(dynamic item, ColorScheme cs) {
    final raw = item.rawTextContent;
    if (raw != null && raw.trim().isNotEmpty) {
      return SingleChildScrollView(
        controller: _scroll,
        child: Text(
          _clean(raw),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16, color: cs.onBackground, height: 1.6),
        ),
      );
    }

    final html = item.textContent;
    if (html != null && html.contains('<img')) {
      final url = _extractImg(html);
      if (url != null) {
        debugPrint('DEBUG[LibraryReadPage] Trying to load image: $url');
        return Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('DEBUG[LibraryReadPage] Image load error for $url: $error');
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('تصویر در دسترس نیست'),
                    Text(
                      url,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    }

    return const Center(child: Text('محتوایی برای نمایش وجود ندارد'));
  }

  /// صفحه‌ی فعلی را بر اساس docContents یا پیام دسترسی نشان می‌دهد
  Widget _buildPageContent(ThesaurusProvider p, ColorScheme cs) {
    if (p.docContents.isEmpty) {
      return const Center(child: Text('محتوایی برای نمایش وجود ندارد'));
    }

    // اگر این صفحه داخل docContents است → محتوا
    if (currentPage >= 0 && currentPage < p.docContents.length) {
      final item = p.docContents[currentPage];
      return _buildContentItem(item, cs);
    }

    // اگر خارج از محدوده‌ی محتوا ولی در page_count است → دسترسی ندارید
    return const Center(
      child: Text(
        'به محتوای این صفحه دسترسی ندارید',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _loadSidePanelsForPage(int page) async {
    final p = Provider.of<ThesaurusProvider>(context, listen: false);

    if (page >= 0 && page < p.docContents.length) {
      final item = p.docContents[page];
      final docContentId = item.id;

      try {
        await p.fetchDocPageIndexes(docContentId);
      } catch (_) {}

      try {
        await p.fetchDocPageTerms(docContentId);
      } catch (_) {}
    } else {
      p.docPageIndexes.clear();
      p.docPageTerms.clear();
    }
  }

  double _boxWidth(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1200) return 800;
    if (w >= 800) return 500;
    return double.infinity;
  }

  double _boxHeight(BuildContext c) =>
      MediaQuery.of(c).size.height * 0.6;

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<ThesaurusProvider>(context);
    final cs = Theme.of(context).colorScheme;

    // تعداد کل صفحات: ترجیح با page_count، در غیر این صورت تعداد محتوا
    final total = p.currentDocPageCount ??
        widget.result.pageCount ??
        p.docContents.length;

    Widget main() {
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
                  foregroundColor: cs.onSurface,
                  side: BorderSide(color: cs.onSurface),
                  minimumSize: const Size(80, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(t(context, 'بازگشت', 'Back', 'رجوع')),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: _boxWidth(context),
                height: _boxHeight(context),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.secondary.withOpacity(0.5)),
                ),
                child: p.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPageContent(p, cs),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: Pagination(
                currentPage: currentPage,
                totalItems: total,
                pageSize: 1,
                onPageChanged: (page) async {
                  setState(() {
                    currentPage = page;
                  });

                  if (_scroll.hasClients) _scroll.jumpTo(0);

                  await _loadSidePanelsForPage(page);
                },
              ),
            ),
          ],
        ),
      );
    }

    Widget side() => Column(
          children: [
            if (p.docPageIndexes.isNotEmpty)
              LibraryIndexesPanel(indexes: p.docPageIndexes),
            if (p.docPageTerms.isNotEmpty)
              LibraryTermsPanel(terms: p.docPageTerms),
          ],
        );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            HeaderWidget(searchQuery: widget.searchQuery),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 800;
                  return wide
                      ? Row(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(child: main()),
                            const SizedBox(width: 16),
                            SizedBox(width: 300, child: side()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            main(),
                            const SizedBox(height: 20),
                            side(),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
