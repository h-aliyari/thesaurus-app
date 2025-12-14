import 'package:flutter/material.dart';
import '../translate.dart';
import 'feature_block.dart';

Widget buildHomeIntro(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final titleColor = const Color(0xFF2F7831); // ثابت در هر دو حالت

  final bodyColor = isDark
      ? const Color(0xFFE0E0E0)
      : const Color.fromARGB(221, 50, 50, 50);

  // رنگ خط زیر تیتر
  final underlineColor = isDark
      ? const Color(0xFF2F7831).withOpacity(0.4)
      : const Color.fromARGB(166, 190, 208, 162);

  final screenWidth = MediaQuery.of(context).size.width;
  final bool isMobile = screenWidth < 600;
  final bool isTablet = screenWidth >= 600 && screenWidth < 900;
  final bool isDesktop = screenWidth >= 900;
  final horizontalPadding = isDesktop ? 120.0 : isTablet ? 90.0 : 60.0;

  return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [

      ///  بخش اول: معرفی اصطلاح‌نامه
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t(context, 'اصطلاحنامه', 'Thesaurus', 'الموسوعه'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.end,
            ),
            Container(
              width: 180,
              height: 4,
              color: underlineColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                context,
                'اصطلاح‏نامه جامع علوم اسلامی مجموعه‏‌اى است مشتمل بر اصطلاحات ، واژه‏‌ها و عناوین درباره حوزه های مختلف علوم اسلامی و حوزه های وابسته . این مجموعه، واژگان زبان نمایه‌ه‏اى كنترل شده‏‌اى است كه به گونه‌‏اى سازمان یافته روابط پیشین میان مفاهیم را روشن مى‏‌كند',
                'The Comprehensive Thesaurus of Islamic Sciences is a collection of terms, words, and titles about various fields of Islamic sciences and related fields. This collection is a controlled index of language vocabulary that clarifies the prior relationships between concepts in an organized manner',
                'المعجم الشامل للعلوم الإسلامية هو مجموعة من المصطلحات والكلمات والعناوين المتعلقة بمختلف مجالات العلوم الإسلامية والمجالات ذات الصلة. تُعدّ هذه المجموعة فهرسًا مُحكمًا لمفردات اللغة، يُوضّح العلاقات السابقة بين المفاهيم بطريقة منظمة.',
              ),
              style: TextStyle(
                fontSize: 16,
                color: bodyColor,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      /// بخش دوم: ThesaurusFeatureBlock full-width
      const ThesaurusFeatureBlock(),

      ///  بخش سوم: معرفی نمایه
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t(context, 'نمایه', 'Index', 'حساب تعريفي'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.end,
            ),
            Container(
              width: 180,
              height: 4,
              color: underlineColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                context,
                'برای بازیابی اطلاعات راه حل های متعددی طرح و به کار گرفته شد و در عمل مورد تجربه قرار گرفت، که در بین آن ها نمایه سازی اطلاعات از همه آن ها مفید تر و کار سازتر تشخیص داده شد.زیرا نمایه کردن اطلاعات موجب جستجوی روان تر و بازیابی سریع تر آن ها خواهد گردید',
                'Several solutions were designed and implemented for information retrieval and were tested in practice, among which information indexing was found to be the most useful and efficient of all. This is because information indexing will result in smoother searching and faster retrieval',
                'تم تصميم وتنفيذ العديد من الحلول لاسترجاع المعلومات، واختبارها عمليًا، ومن بينها فهرسة المعلومات الأكثر فائدة وفعالية، إذ تُسهّل عملية البحث وتسرع عملية الاسترجاع'
              ),
              style: TextStyle(
                fontSize: 16,
                color: bodyColor,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      /// بخش چهارم: عضویت در گنجینه اصطلاحات
      LayoutBuilder(
        builder: (context, constraints) {
          final bool stackVertical = isMobile || isTablet;
          return Container(
            width: double.infinity,
            height: 550,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pictures/alpha_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 50),
            child: stackVertical
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        t(context, 'با عضویت در گنجینه اصطلاحات علوم اسلامی',
                        'By subscribing to the Treasury of Islamic Sciences Terms',
                        'بالاشتراك في شروط خزانة العلوم الإسلامية'
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 16),
                      _buildCheckItem(
                        context,
                        t(
                          context,
                          'به لیستی از اصطلاحات که جستجو کرده اید دسترسی داشته باشید',
                          'Access a list of terms you have searched for',
                          'الوصول إلى قائمة المصطلحات التي بحثت عنها'
                        ),
                      ),
                      _buildCheckItem(
                        context,
                        t(
                          context,
                          'اصطلاحات و نمایه ها را به لیست علاقه مندی های خود اضافه کنید',
                          'Add terms and profiles to your favorites list',
                          'أضف المصطلحات والملفات الشخصية إلى قائمة المفضلة لديك'
                        ),
                      ),
                      _buildCheckItem(
                        context,
                        t(
                          context,
                          'اصطلاحات مورد نظر خود را به گنجینه پیشنهاد دهید',
                          'Suggest your desired terms to the treasury.',
                          'اقترح الشروط المطلوبة للخزينة.'
                        ),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/pictures/laptop.png',
                        fit: BoxFit.contain,
                        width: constraints.maxWidth * 0.53,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              t(context, 'با عضویت در گنجینه اصطلاحات علوم اسلامی',
                              'By subscribing to the Treasury of Islamic Sciences Terms',
                              'بالاشتراك في شروط خزانة العلوم الإسلامية'
                              ),
                              style: const TextStyle(
                                  fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                            const SizedBox(height: 16),
                            _buildCheckItem(
                        context,
                        t(
                          context,
                          'به لیستی از اصطلاحات که جستجو کرده اید دسترسی داشته باشید',
                          'Access a list of terms you have searched for',
                          'الوصول إلى قائمة المصطلحات التي بحثت عنها'
                        ),
                      ),
                      _buildCheckItem(
                        context,
                        t(
                          context,
                          'اصطلاحات و نمایه ها را به لیست علاقه مندی های خود اضافه کنید',
                          'Add terms and profiles to your favorites list',
                          'أضف المصطلحات والملفات الشخصية إلى قائمة المفضلة لديك'
                        ),
                      ),
                      _buildCheckItem(
                        context,
                        t(
                          context,
                          'اصطلاحات مورد نظر خود را به گنجینه پیشنهاد دهید',
                          'Suggest your desired terms to the treasury.',
                          'اقترح الشروط المطلوبة للخزينة.'
                        ),
                      ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/pictures/laptop.png',
                          height: 250,
                          width: 150,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),

      /// بخش پنجم: فرهنگنامه
      Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              t(context, 'فرهنگنامه', 'Lexicon', 'المعجم'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.end,
            ),
            Container(
              width: 180,
              height: 4,
              color: underlineColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            const SizedBox(height: 16),
            Text(
              t(
                context,
                'برای آن دسته از مخاطبان كه خواهان دریافت اطلاعات اساسی و زبده پیرامون یك موضوع (یا اصطلاح) خاص به زبان ساده همراه با آراء و اقوال متخصصان برجسته آن علم و با صرف زمان كوتاه ، بهترین شیوه برای پاسخ به نیاز این دسته از مخاطبان - كه از نظر كمٌی در اكثریت نیز قرار دارند عرضه اطلاعات از طریق فرهنگ نامه می باشد ',
                'For those audiences who want to receive basic and expert information about a specific topic (or term) in simple language, along with the opinions and statements of prominent experts in that field, and in a short amount of time, the best way to meet the needs of this audience - who are also in the majority in terms of quantity - is to provide information through a dictionary.',
                'بالنسبة للفئة التي تريد الحصول على معلومات أساسية وخبيرة حول موضوع معين (أو مصطلح) بلغة بسيطة، إلى جانب آراء وتصريحات خبراء بارزين في هذا المجال، وفي فترة زمنية قصيرة، فإن أفضل طريقة لتلبية احتياجات هذا الجمهور -الذين يشكلون أيضًا الأغلبية من حيث الكمية- هي توفير المعلومات من خلال القاموس.'
              ),
              style: TextStyle(
                fontSize: 16,
                color: bodyColor,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ],
  ));
}

/// ویجت کمکی برای یک خط با تیک
Widget _buildCheckItem(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        const Icon(Icons.check, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ),
      ],
    ),
  );
}