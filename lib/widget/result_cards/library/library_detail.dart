import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/result.dart';
import 'library_detail_header.dart';
import '../../../screen/translate.dart';
import 'library_detail_info.dart';
import 'graphs/library_graph.dart';
import 'library_read_page.dart';
import '../../../provider/thesaurus_provider.dart';

class LibraryDetailPage extends StatefulWidget {
  final ThesaurusResult result;
  final String searchQuery;

  const LibraryDetailPage({
    super.key,
    required this.result,
    this.searchQuery = '',
  });

  @override
  State<LibraryDetailPage> createState() => _LibraryDetailPageState();
}

class _LibraryDetailPageState extends State<LibraryDetailPage> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ThesaurusProvider>(context, listen: false);
      final idStr = widget.result.id;
      if (idStr != null && idStr.trim().isNotEmpty) {
        final id = int.tryParse(idStr.trim());
        if (id != null) {
          provider.fetchDocWithContents(id);
        }
      }
    });
  }

  Widget _rightColumn(BuildContext context, bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Consumer<ThesaurusProvider>(
            builder: (context, provider, _) {
              final docMap = provider.docDetails;
              if (docMap != null && docMap.isNotEmpty) {
                final merged = Map<String, dynamic>.from(docMap);

                if (merged['details'] == null && docMap['details'] != null) {
                  merged['details'] = docMap['details'];
                }

                final detailResult = ThesaurusResult.fromJson({'doc': merged, 'details': merged['details']});

                return LibraryDetailInfo(result: detailResult);
              }

              return LibraryDetailInfo(result: widget.result);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(180, 40),
              backgroundColor: isDark ? const Color.fromARGB(255, 111, 197, 114) : Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LibraryReadPage(result: widget.result),
                ),
              );
            },
            child: Text(
              t(context, 'مطالعه', 'Read', 'اقرأ'),
              style: TextStyle(color: isDark ? Colors.black : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftBox(BuildContext context, bool isTabletOrDesktop, bool isDark, ColorScheme cs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteHeight = constraints.hasBoundedHeight;
        final hasFiniteWidth = constraints.hasBoundedWidth;

        double side;
        if (hasFiniteWidth && hasFiniteHeight) {
          side = constraints.biggest.shortestSide;
        } else {
          final screen = MediaQuery.of(context).size;
          side = isTabletOrDesktop ? screen.width * 0.35 : screen.width * 0.8;
          side = side.clamp(280.0, 560.0);
        }

        return Container(
          margin: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.secondary.withOpacity(0.5), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: side,
              height: side,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Consumer<ThesaurusProvider>(
                  builder: (context, provider, _) {
                    return LibraryGraph(result: widget.result, terms: provider.docTerms);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = w > 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
      body: Column(
        children: [
          HeaderWidget(searchQuery: widget.searchQuery),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: isTabletOrDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _leftBox(context, isTabletOrDesktop, isDark, cs)),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _rightColumn(context, isDark, cs)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _rightColumn(context, isDark, cs),
                        const SizedBox(height: 20),
                        _leftBox(context, isTabletOrDesktop, isDark, cs),
                      ],
                    ),
            ),
          ),
        ],
      ),)
    );
  }
}