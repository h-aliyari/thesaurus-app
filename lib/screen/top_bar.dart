import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'translate.dart';
import 'top_menu.dart';
import '../provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'logo_menu.dart';

class TopBar extends StatelessWidget {
  final double screenWidth;
  final void Function(String) onLanguageChange;

  const TopBar({
    super.key,
    required this.screenWidth,
    required this.onLanguageChange,
  });

  TextStyle _textStyle({bool bold = false, double size = 14, Color? color}) {
    return TextStyle(
      fontFamily: 'IranSans',
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: size,
      color: color ?? Colors.white,
    );
  }

  ///  تابع مشترک ساخت لیست زبان‌ها
  List<PopupMenuEntry<String>> _buildLanguageMenuItems(
      BuildContext context, Color textColor) {
    return [
      PopupMenuItem(
        value: 'fa',
        child: Row(
          children: [
            Image.asset('assets/pictures/flags/ir.png', width: 26, height: 26),
            const SizedBox(width: 8),
            Text('فارسی',
                style: _textStyle(color: textColor)),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'ar',
        child: Row(
          children: [
            Image.asset('assets/pictures/flags/sa.png', width: 26, height: 26),
            const SizedBox(width: 8),
            Text('العربیه',
                style: _textStyle(color: textColor)),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'en',
        child: Row(
          children: [
            Image.asset('assets/pictures/flags/us.png', width: 26, height: 26),
            const SizedBox(width: 8),
            Text('English',
                style: _textStyle(color: textColor)),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child:LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 800;

        final textColor = context.watch<ThemeProvider>().isDark
            ? Colors.white
            : Colors.black;

        final GlobalKey<PopupMenuButtonState<String>> _langBtnKey =
            GlobalKey<PopupMenuButtonState<String>>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // سمت چپ
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          context.watch<ThemeProvider>().isDark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),

                      const SizedBox(width: 50),

                      /// ورود و ثبت‌نام (حالت بزرگ)
                      if (isLarge) ...[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => context.push('/register_home'),
                            child: Text(
                              t(context, 'ثبت‌نام', 'Register', 'يسجل'),
                              style: _textStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('/', style: _textStyle()),
                        const SizedBox(width: 6),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => context.push('/login'),
                            child: Text(
                              t(context, 'ورود', 'Login', 'تسجيل الدخول'),
                              style: _textStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      /// آیکون یوزر
                      PopupMenuButton<String>(
                        tooltip: t(context, 'انتخاب', 'Select', 'انتخاب'),
                        icon: Image.asset(
                          'assets/pictures/user_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        onSelected: (value) {
                          if (value == 'login') context.push('/login');
                          if (value == 'register') context.push('/register_home');
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'register',
                            child: Text(
                              t(context, 'ثبت‌نام', 'Register', 'يسجل'),
                              style: _textStyle(color: textColor),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'login',
                            child: Text(
                              t(context, 'ورود', 'Login', 'تسجيل الدخول'),
                              style: _textStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      /// متن زبان‌ها (کلیک مثل آیکون)
                      if (isLarge)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              _langBtnKey.currentState!.showButtonMenu();
                            },
                            child: Text(
                              t(context, 'زبان‌ها', 'Languages', 'لغة'),
                              style: _textStyle(),
                            ),
                          ),
                        ),

                      const SizedBox(width: 6),

                      /// -----------------------------
                      /// آیکون انتخاب زبان
                      /// -----------------------------
                      PopupMenuButton<String>(
                        key: _langBtnKey,
                        tooltip: t(context, 'انتخاب زبان', 'Choose language', 'اختيار اللغة'),
                        icon: Image.asset(
                          'assets/pictures/lan_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        onSelected: onLanguageChange,
                        itemBuilder: (_) =>
                            _buildLanguageMenuItems(context, textColor),
                      ),
                    ],
                  ),

                  // وسط (TopMenu فقط در حالت بزرگ)
                  if (screenWidth >= 960)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Center(child: TopMenu()),
                      ),
                    ),

                  // راست: لوگو و عنوان
                  Row(
                    children: [
                      // برود هوم
                      if (screenWidth > 600)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => context.go('/home'),
                            child: Text(
                              t(
                                context,
                                'پژوهشکده مدیریت اطلاعات و مدارک اسلامی',
                                'Islamic Information Research Center',
                                'معهد أبحاث إدارة المعلومات والوثائق الإسلامية',
                              ),
                              style: _textStyle(bold: true, size: 13),
                            ),
                          ),
                        ),

                      const SizedBox(width: 8),

                      // باز کردن منوی کشویی
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black54,
                              builder: (_) => const LogoMenu(),
                            );
                          },
                          child: Image.asset(
                            'assets/pictures/logo-w.png',
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            /// TopMenu برای حالت کوچک
            if (screenWidth < 960)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: TopMenu(),
              ),
          ],
        );
      },
      ),
    );
  }
}
