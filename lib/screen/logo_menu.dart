import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 26),
                      ),
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
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => context.push('/login'),
                          child: const Icon(Icons.person, size: 22),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ورود
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
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
                      ),
                      const SizedBox(width: 12),

                      // ثبت‌نام
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _menuItem(context, 'خانه', '/home'),
                _menuItem(context, 'اصطلاحنامه', '/thesaurus'),
                _menuItem(context, 'فرهنگنامه', '/lexicon'),
                _menuItem(context, 'نمایه', '/index'),
                _menuItem(context, 'کتابخانه', '/resources'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String title, String route) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.centerRight,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
