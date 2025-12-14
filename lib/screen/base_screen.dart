import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../provider/thesaurus_provider.dart';
import '../widget/result_cards/all_result_cards.dart';
import '../../widget/scroll_bar.dart';
import '../../widget/loading.dart';
import 'search_box.dart';
import 'top_bar.dart';
import 'gradient.dart';

class FullWidthWidget extends StatelessWidget {
  final Widget child;
  const FullWidthWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: child);
}

class BaseScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showCategoryDropdown;
  final List<String> Function(BuildContext) categoriesBuilder;
  final String? defaultCategory;
  final bool showIntro;
  final Widget? customIntro;
  final void Function(BuildContext, String, String) onSearch;
  final bool isHome;
  final Widget? pageResults;
  final String? initialSearchQuery;

  const BaseScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showCategoryDropdown,
    required this.categoriesBuilder,
    this.defaultCategory,
    required this.showIntro,
    this.customIntro,
    required this.onSearch,
    this.isHome = false,
    this.pageResults,
    this.initialSearchQuery,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late final TextEditingController textController;
  final ScrollController scrollController = ScrollController();
  bool searched = false;
  late String selectedCategory;
  ThesaurusProvider? _provider;
  VoidCallback? _providerListener;

  @override
  void initState() {
    super.initState();
    selectedCategory =
        widget.showCategoryDropdown ? (widget.defaultCategory ?? '') : '';

    textController = TextEditingController(text: widget.initialSearchQuery ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachProviderListener();

      final prov = Provider.of<ThesaurusProvider>(context, listen: false);

      if ((widget.initialSearchQuery == null || widget.initialSearchQuery!.trim().isEmpty) &&
          prov.lastQuery.isNotEmpty &&
          textController.text != prov.lastQuery) {
        textController.text = prov.lastQuery;
        textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
      }

      final currentText = textController.text.trim();
      if (currentText.isNotEmpty && !searched) {
        Future.microtask(() {
          widget.onSearch(context, currentText, selectedCategory);
          setState(() => searched = true);
        });
      }
    });
  }

  void _attachProviderListener() {
    if (_provider != null && _providerListener != null) {
      _provider!.removeListener(_providerListener!);
    }

    _provider = Provider.of<ThesaurusProvider>(context, listen: false);
    _providerListener = () {
      final last = _provider?.lastQuery ?? '';
      if (last.isNotEmpty && textController.text != last) {
        textController.text = last;
        textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
        if (!searched) {
          Future.microtask(() {
            widget.onSearch(context, last, selectedCategory);
            setState(() => searched = true);
            debugPrint('BaseScreen: auto-triggered search from provider for "$last"');
          });
        }
      }
    };
    _provider?.addListener(_providerListener!);
  }

  @override
  void dispose() {
    if (_provider != null && _providerListener != null) {
      _provider!.removeListener(_providerListener!);
    }
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Consumer<ThesaurusProvider>(
        builder: (context, provider, child) {
          final categories = widget.showCategoryDropdown
              ? List<String>.from(widget.categoriesBuilder(context))
              : <String>[];

          if (!categories.contains(selectedCategory) && categories.isNotEmpty) {
            selectedCategory = categories.first;
          }

          return Stack(
            children: [
              Scaffold(
                body: Column(
                  children: [
                    /// TopBar
                    SafeArea(
                      child: Container(
                        decoration: buildGradient(context),
                        child: TopBar(
                          screenWidth: MediaQuery.of(context).size.width,
                          onLanguageChange: (lang) {
                            provider.setLocale(lang);
                            setState(() {
                              selectedCategory =
                                  widget.defaultCategory ?? categories.first;
                            });
                          },
                        ),
                      ),
                    ),

                    /// محتوا
                    Expanded(
                      child: NestedScrollView(
                        controller: scrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(
                            expandedHeight: 300,
                            pinned: false,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Container(
                                decoration: buildGradient(context),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: SvgPicture.asset(
                                        'assets/pictures/graph1.svg',
                                        width: 120,
                                        height: 350,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.title,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (widget.subtitle.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  widget.subtitle,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 30),

                                            /// سرچ‌باکس
                                            SearchBox(
                                              controller: textController,
                                              selectedCategory: selectedCategory,
                                              categories: categories,
                                              onCategoryChange: (v) =>
                                                  setState(() =>
                                                      selectedCategory = v),
                                              onSearch: (q) {
                                                widget.onSearch(
                                                    context, q, selectedCategory);
                                                setState(() => searched = true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        body: Stack(
                          children: [
                            SingleChildScrollView(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                children: [
                                  /// نتایج زیر هدر
                                  if (searched)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: widget.isHome
                                          ? AllResultCards(
                                              resultsByService: provider.byService,
                                              resultCounts: provider.counts,
                                            )
                                          : widget.pageResults ?? const SizedBox.shrink(),
                                    ),

                                  /// اینترو
                                  if (widget.showIntro && widget.customIntro != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30),
                                      child: widget.customIntro!,
                                    ),

                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),

                            /// ScrollBar دسکتاپ
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: DesktopScrollbar(controller: scrollController),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Loading Overlay
              if (provider.isLoading) const LoadingOverlay(),
            ],
          );
        },
      )
    );
  }
}
