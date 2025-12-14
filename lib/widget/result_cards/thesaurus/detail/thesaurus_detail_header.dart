import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../screen/gradient.dart';
import '../../../../service/thesaurus_extra.dart';
import '../../../../screen/search_box.dart';

class ThesaurusDetailHeader extends StatefulWidget {
  final String searchQuery;
  final String? selectedDomain;

  const ThesaurusDetailHeader({
    super.key,
    this.searchQuery = '',
    this.selectedDomain,
  });

  @override
  State<ThesaurusDetailHeader> createState() => _ThesaurusDetailHeaderState();
}

class _ThesaurusDetailHeaderState extends State<ThesaurusDetailHeader> {
  final _controller = TextEditingController();
  String selectedCategory = 'دامنه';
  List<Map<String, dynamic>> domains = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;

    if (widget.selectedDomain != null) {
      selectedCategory = widget.selectedDomain!;
    }

    _loadDomains();
  }

  Future<void> _loadDomains() async {
    final result = await ThesaurusExtra.fetchDomains();
    if (!mounted) return;
    setState(() => domains = result);
  }

  void _onSearch(String q) {
    if (q.trim().isEmpty) return;

    if (selectedCategory == 'دامنه') {
      context.go('/thesaurus?query=$q&domain=0');
    } else {
      final domain = domains.firstWhere(
        (d) => d['title'] == selectedCategory,
        orElse: () => <String, dynamic>{},
      );

      final domainParam = domain.isNotEmpty ? '&domain=${domain['id']}' : '&domain=0';
      context.go('/thesaurus?query=$q$domainParam');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1000, isTablet = w > 600 && w <= 1000, isMobile = w <= 600;
    final h = isDesktop ? 100.0 : isTablet ? 88.0 : 50.0;

    final categories = ['دامنه', ...domains.map((d) => d['title']?.toString() ?? '')];

    return Container(
      height: h,
      decoration: buildGradient(context),
      child: Stack(children: [
        // لوگو + متن
        Positioned(
          right: 0,
          top: 8,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/home'),
              child: isMobile
                  ? Row(
                      children: [
                        const Text(
                          'پژوهشکده مدیریت اطلاعات و مدارک اسلامی',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/pictures/logo-w.png', height: 28),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/pictures/logo-w.png',
                          height: isDesktop ? 50 : 44,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'پژوهشکده مدیریت اطلاعات و مدارک اسلامی',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),


        // سرچ + دسته‌ها
        if (!isMobile)
          Positioned(
            left: 16,
            top: h / 2 - 20,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _onSearch(_controller.text),
                ),
                const SizedBox(width: 8),

                // Dropdown دامنه‌ها با HoverMenuItem
                if (categories.isNotEmpty)
                  PopupMenuButton<String>(
                    onSelected: (value) => setState(() => selectedCategory = value),
                    padding: EdgeInsets.zero,
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: (categories.length * 32.0).clamp(0, 300.0),
                          width: 180,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return HoverMenuItem(
                                text: cat,
                                fontSize: 15,
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => selectedCategory = cat);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_drop_down,
                            size: 22, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(selectedCategory,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                const SizedBox(width: 12),

                SizedBox(
                  width: isDesktop ? 220 : 160,
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'عبارت جستجو',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    textAlign: TextAlign.right,
                    onSubmitted: _onSearch,
                  ),
                ),
              ]),
            ),
          ),

        // منو وسط
        if (!isMobile)
          Align(
            alignment: Alignment.center,
            child: _buildMenu(context,
                isTablet ? w * 0.5 : (isDesktop ? w * 0.6 : w * 0.8)),
          ),
      ]),
    );
  }

  Widget _buildMenu(BuildContext ctx, double maxWidth) {
    final items = [
      {'fa': 'اصطلاحنامه', 'path': '/thesaurus'},
      {'fa': 'فرهنگنامه', 'path': '/lexicon'},
      {'fa': 'نمایه', 'path': '/index'},
      {'fa': 'کتابخانه', 'path': '/resources'},
      {'fa': 'ثبت‌نام', 'path': '/register'},
      {'fa': 'ورود', 'path': '/login'},
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return Container(width: 1.5, height: 18, color: Colors.white);
          final it = items[i ~/ 2];
          return TextButton(
            onPressed: () => ctx.push(it['path']!),
            child: Text(
              it['fa']!,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          );
        }),
      ),)
    );
  }
}