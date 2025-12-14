import 'package:flutter/material.dart';

class ThesaurusOptionsBar extends StatelessWidget {
  final String activeLabel;
  final Function(String) onSelect;

  final int indexCount;
  final int relationCount;

  const ThesaurusOptionsBar({
    super.key,
    required this.activeLabel,
    required this.onSelect,
    required this.indexCount,
    required this.relationCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 500;

    final options = [
      {'icon': Icons.article, 'label': 'نمایه', 'count': indexCount},
      {'icon': Icons.source, 'label': 'منابع', 'count': null},
      {'icon': Icons.menu_book, 'label': 'فرهنگنامه', 'count': null},
      {'icon': Icons.account_tree_rounded, 'label': 'درختواره', 'count': null},
      {'icon': Icons.share, 'label': 'رابطه', 'count': relationCount},
    ];

    final activeIndex = options.indexWhere((o) => o['label'] == activeLabel);

    return SizedBox(
      height: isMobile ? 46 : 50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / options.length;

          final indicatorWidth = isMobile
              ? (itemWidth * 0.55).toDouble()
              : 100.0;

          final removeIcons = itemWidth < 70;

          return Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: options.map((opt) {
                  final label = opt['label'] as String;
                  final icon = opt['icon'] as IconData;
                  final count = opt['count'];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelect(label),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4 : 12,
                        vertical: isMobile ? 4 : 6,
                      ),
                      child: Row(
                        children: [
                          // متن همیشه نمایش داده می‌شود
                          Text(
                            label,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (count != null) SizedBox(width: isMobile ? 3 : 4),

                          if (count != null)
                            Text(
                              "$count",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          // اگر جا کم بود → آیکون حذف می‌شود
                          if (!removeIcons) SizedBox(width: isMobile ? 4 : 6),

                          if (!removeIcons)
                            Icon(
                              icon,
                              size: isMobile ? 16 : 18,
                              color: Colors.blueGrey,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // خط انتخاب‌شونده
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: activeIndex * itemWidth + (itemWidth - indicatorWidth) / 2,
                bottom: 0,
                child: Container(
                  height: 2,
                  width: indicatorWidth,
                  color: cs.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}