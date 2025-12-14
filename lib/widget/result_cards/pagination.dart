import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;       // صفحه فعلی
  final int totalItems;        // تعداد کل صفحات (از page_count)
  final int pageSize;          // اندازه صفحه (اینجا همیشه 1)
  final ValueChanged<int> onPageChanged;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  String _toPersianNumber(int number) {
    const english = ['0','1','2','3','4','5','6','7','8','9'];
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    return number.toString().split('').map((e) {
      final i = english.indexOf(e);
      return i >= 0 ? persian[i] : e;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalPages = (totalItems / pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = <int>[];

    if (totalPages <= 6) {
      pages.addAll(List.generate(totalPages, (i) => i));
    } else {
      if (currentPage <= 1) {
        pages.addAll([0, 1]);
        pages.add(-1);
        pages.addAll([totalPages - 2, totalPages - 1]);
      } else if (currentPage >= totalPages - 2) {
        pages.addAll([0, 1]);
        pages.add(-1);
        pages.addAll([totalPages - 2, totalPages - 1]);
      } else {
        pages.addAll([0, 1]);
        pages.add(-1);
        pages.add(currentPage);
        pages.add(-2);
        pages.addAll([totalPages - 2, totalPages - 1]);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.secondary),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          _buildPageBox('》', currentPage > 0 ? () => onPageChanged(currentPage - 1) : null, cs),
          ...pages.map((i) {
            if (i == -1 || i == -2) {
              return Container(
                width: 40,
                height: 36,
                alignment: Alignment.center,
                child: Text('...', style: TextStyle(color: cs.secondary)),
              );
            }
            final isActive = i == currentPage;
            return _buildPageBox(
              _toPersianNumber(i + 1),
              () => onPageChanged(i),
              cs,
              isActive: isActive,
            );
          }),
          _buildPageBox('《', currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null, cs),
        ],
      ),
    );
  }

  Widget _buildPageBox(
    String label,
    VoidCallback? onPressed,
    ColorScheme cs, {
    bool isActive = false,
  }) {
    return Container(
      width: 50,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : cs.surface,
        border: Border(right: BorderSide(color: cs.secondary)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : cs.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}