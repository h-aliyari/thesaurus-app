import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'translate.dart';

class LogoMenu extends StatelessWidget {
  const LogoMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topRight,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            margin: const EdgeInsets.only(top: 20, right: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ردیف بالا: لوگو + ضربدر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/pictures/logo.png',
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 26),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // عنوان
                Center(
                  child: Text(
                    'پژوهشکده مدیریت اطلاعات و مدارک اسلامی',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // ورود / ثبت‌نام
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: const Icon(Icons.person, size: 22),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Text(
                          t(context, 'ورود', 'Login', 'تسجيل الدخول'),
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/register_home'),
                        child: Text(
                          t(context, 'ثبت‌نام', 'Register', 'يسجل'),
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _HoverSelectableItem(
                  title: 'خانه',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                ),
                _HoverSelectableItem(
                  title: 'اصطلاحنامه',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/thesaurus');
                  },
                ),
                _HoverSelectableItem(
                  title: 'فرهنگنامه',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/lexicon');
                  },
                ),
                _HoverSelectableItem(
                  title: 'نمایه',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/index');
                  },
                ),
                _HoverSelectableItem(
                  title: 'کتابخانه',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/resources');
                  },
                ),
                _HoverSelectableItem(
                  title: 'به‌روزرسانی اپ',
                  leading: const Icon(Icons.update, size: 18),
                  onTap: () {
                    Navigator.pop(context);
                    // ساده‌ترین رفتار به‌روزرسانی: بستن و باز شدن مجدد اپ توسط کاربر
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ویجت آیتم منو با رفتار هاور و انتخاب‌شدن
class _HoverSelectableItem extends StatefulWidget {
  final String title;
  final Widget? leading;
  final VoidCallback onTap;

  const _HoverSelectableItem({
    required this.title,
    required this.onTap,
    this.leading,
  });

  @override
  State<_HoverSelectableItem> createState() => _HoverSelectableItemState();
}

class _HoverSelectableItemState extends State<_HoverSelectableItem> {
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = _isSelected
        ? Colors.lightBlueAccent.withValues(alpha: 0.3) // وقتی انتخاب شد
        : _isHovered
            ? Colors.grey.withValues(alpha: 0.3) // وقتی هاور شد
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => _isSelected = true);
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
