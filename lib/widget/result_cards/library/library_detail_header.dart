import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../screen/gradient.dart';
import '../../../screen/translate.dart';

class HeaderWidget extends StatefulWidget {
  final String searchQuery;
  const HeaderWidget({super.key, this.searchQuery = ''});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  bool showMobileSearch = false;
  final TextEditingController _controller = TextEditingController();
  static const double searchBoxHeight = 40;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;

    if (_searching) return;
    setState(() => _searching = true);

    try {
      FocusScope.of(context).unfocus();
      context.push('/resources?query=${Uri.encodeComponent(query)}');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Widget _buildMenu(BuildContext ctx, double maxWidth) {
    final items = [
      {'fa': 'اصطلاحنامه', 'en': 'Thesaurus', 'ar': 'الموسوعه', 'path': '/thesaurus'},
      {'fa': 'فرهنگنامه', 'en': 'Lexicon', 'ar': 'المعجم', 'path': '/lexicon'},
      {'fa': 'نمایه', 'en': 'Index', 'ar': 'الفهرس', 'path': '/index'},
      {'fa': 'کتابخانه', 'en': 'Library', 'ar': 'المكتبة', 'path': '/resources'},
      {'fa': 'ثبت‌نام', 'en': 'Register', 'ar': 'تسجيل', 'path': '/register'},
      {'fa': 'ورود', 'en': 'Login', 'ar': 'تسجيل الدخول', 'path': '/login'},
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
                t(ctx, it['fa']!, it['en']!, it['ar']),
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 1000, isTablet = w > 600 && w <= 1000, isMobile = w <= 600;
    final h = isDesktop ? 100.0 : isTablet ? 88.0 : 50.0;

    return Container(
      height: h,
      decoration: buildGradient(context),
      child: Stack(
        children: [
          // لوگو + تیتر → هر دو می‌روند /home
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

          // سرچ
          if (!isMobile)
            Positioned(
              left: 16,
              top: h / 2 - searchBoxHeight / 2,
              child: Container(
                height: searchBoxHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: _searching
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _onSearch(_controller.text),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: isDesktop ? 280 : 200,
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
                        onSubmitted: (v) => _onSearch(v),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Positioned(
              left: 12,
              top: 12,
              child: showMobileSearch
                  ? Container(
                      height: searchBoxHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: _searching
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () => _onSearch(_controller.text),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText: 'عبارت جستجو',
                                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              textAlign: TextAlign.right,
                              onSubmitted: (v) => _onSearch(v),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => showMobileSearch = false),
                          ),
                        ],
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => setState(() => showMobileSearch = true),
                    ),
            ),

          // منو وسط
          if (!isMobile)
            Align(
              alignment: Alignment.center,
              child: _buildMenu(context, isTablet ? w * 0.5 : (isDesktop ? w * 0.6 : w * 0.8)),
            ),
        ],
      ),
    );
  }
}