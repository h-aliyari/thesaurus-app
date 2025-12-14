import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../base_screen.dart';
import '../../provider/thesaurus_provider.dart';
import '../../service/thesaurus_api.dart';
import '../intros/home_intro.dart';
import '../translate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: t(
        context,
        'پایگاه مدیریت اطلاعات علوم اسلامی',
        'Islamic Information Management Center',
        'قاعدة بيانات إدارة معلومات العلوم الإسلامية',
      ),
      subtitle: '',
      showCategoryDropdown: true,
      categoriesBuilder: (ctx) => [
        t(ctx, 'جستجو در', 'Search in', 'بحث في'),
        t(ctx, 'اصطلاحنامه', 'Thesaurus', 'الموسوعة'),
        t(ctx, 'فرهنگنامه', 'Lexicon', 'المعجم'),
        t(ctx, 'نمایه', 'Index', 'الفهرس'),
        t(ctx, 'کتابخانه', 'Library', 'المكتبة'),
      ],
      defaultCategory: t(context, 'جستجو در', 'Search in', 'بحث في'),
      showIntro: true,
      customIntro: buildHomeIntro(context),
      onSearch: (context, query, selectedCategory) async {
        final provider = context.read<ThesaurusProvider>();
        provider.clear();

        switch (selectedCategory) {
          case 'جستجو در':
            await provider.searchAll(query);
            break;
          case 'اصطلاحنامه':
            await provider.searchSingle(ThesaurusService.thesaurus, 'اصطلاحنامه', query);
            break;
          case 'فرهنگنامه':
            await provider.searchSingle(ThesaurusService.lexicon, 'فرهنگنامه', query);
            break;
          case 'نمایه':
            await provider.searchSingle(ThesaurusService.indexService, 'نمایه', query);
            break;
          case 'کتابخانه':
            await provider.searchSingle(ThesaurusService.resources, 'کتابخانه', query);
            break;
        }
      },
      isHome: true,
    );
  }
}