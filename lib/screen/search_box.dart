import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'translate.dart';
import '../widget/scroll_bar.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCategory;
  final List<String> categories;
  final void Function(String) onCategoryChange;
  final void Function(String) onSearch;

  const SearchBox({
    super.key,
    required this.controller,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChange,
    required this.onSearch,
  });

  static const double _height = 40;
  static const double _fontSize = 15;
  static const double _categoryMaxWidth = 200;
  static const String _searchIconPath = 'assets/pictures/search_icon.svg';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final languageCode = Localizations.localeOf(context).languageCode;
    final scrollController = ScrollController();
    final double categoryMenuHeight = (categories.length * 32.0).clamp(0, 350.0);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Container(
          width: isMobile ? double.infinity : MediaQuery.of(context).size.width * 0.5,
          height: _height,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final query = controller.text.trim();
                  if (query.isNotEmpty) onSearch(query);
                },
                child: SvgPicture.asset(_searchIconPath, width: 24, height: 24),
              ),
              const SizedBox(width: 15),

              if (categories.isNotEmpty)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    onCategoryChange(value);
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: categoryMenuHeight,
                        width: isMobile ? 120 : _categoryMaxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(scrollbars: false),
                          child: Stack(
                            children: [
                              ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.zero,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  return HoverMenuItem(
                                    text: cat,
                                    fontSize: _fontSize,
                                    onTap: () {
                                      onCategoryChange(cat);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                              if (!isMobile && categories.length > 5)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: DesktopScrollbar(
                                    controller: scrollController,
                                    leftSide: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_drop_down, size: 22, color: Colors.black),
                      if (!isMobile) ...[
                        const SizedBox(width: 10),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: _categoryMaxWidth),
                          child: Text(
                            selectedCategory,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: _fontSize, color: Colors.black),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: languageCode == 'fa' ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(fontSize: _fontSize, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: t(
                      context,
                      'عبارت مورد نظرتان را وارد کنید',
                      'Enter your search term',
                      'أدخل العبارة المطلوبة.',
                    ),
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (v) {
                    final query = v.trim();
                    if (query.isNotEmpty) onSearch(query);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverMenuItem extends StatefulWidget {
  final String text;
  final double fontSize;
  final VoidCallback onTap;

  const HoverMenuItem({
    super.key,
    required this.text,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<HoverMenuItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          color: _hovering ? Colors.blue : Colors.transparent,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: _hovering ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}