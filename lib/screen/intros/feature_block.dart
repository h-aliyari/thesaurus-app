import 'package:flutter/material.dart';
import '../translate.dart';

class ThesaurusFeatureBlock extends StatelessWidget {
  final VoidCallback? onVideoPressed;
  final Color lightbackgroundColor;
  final Color darkbackgroundColor;

  const ThesaurusFeatureBlock({
    super.key,
    this.onVideoPressed,
    this.lightbackgroundColor = const Color(0xFFF0F0F0),
    this.darkbackgroundColor = const Color.fromARGB(255, 56, 56, 56),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark ? darkbackgroundColor : lightbackgroundColor;

    final bool isMobile = screenWidth < 700;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1100;
    final bool isDesktop = screenWidth >= 1100;

    final bool useColumnLayout = isMobile || isTablet;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120 : isTablet ? 90 : 60,
        vertical: isDesktop ? 70 : isTablet ? 50 : 35,
      ),
      child: useColumnLayout
          ? _buildColumnLayout(context, isTablet, isDesktop, isDark, scheme)
          : _buildRowLayout(context, isTablet, isDesktop, isDark, scheme),
    ));
  }

  Widget _buildRowLayout(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    bool isDark,
    ColorScheme scheme,
  ) {
    final imageWidth = isDesktop ? 520 : isTablet ? 360 : 280;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: isDesktop ? 60 : 20),
        SizedBox(
          width: imageWidth.toDouble(),
          child: Image.asset('assets/pictures/key2.png', fit: BoxFit.contain),
        ),
        SizedBox(width: isDesktop ? 120 : 60),
        Expanded(
          child: _buildTextContent(context, isTablet, isDesktop, isDark, scheme),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    bool isDark,
    ColorScheme scheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextContent(context, isTablet, isDesktop, isDark, scheme),
        const SizedBox(height: 20),
        Image.asset(
          'assets/pictures/key2.png',
          fit: BoxFit.contain,
          height: isDesktop ? 450 : isTablet ? 360 : 280,
        ),
      ],
    );
  }

  // TEXT + BUTTON
  Widget _buildTextContent(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
    bool isDark,
    ColorScheme scheme,
  ) {
    final titleFont = isDesktop ? 26 : isTablet ? 22 : 20;
    final bodyFont = isDesktop ? 17 : isTablet ? 16 : 15;

    final Color titleColor =
        isDark ? scheme.primary : const Color(0xFF2F7831);

    final Color bodyColor =
        isDark ? scheme.onSurface : Colors.black87;

    final Color underlineColor =
        isDark ? scheme.primary.withOpacity(0.4) : const Color.fromARGB(166, 190, 208, 162);

    final Color buttonBackground =
        isDark ? scheme.primary : const Color(0xFF2F7831);

    final Color buttonForeground =
        isDark ? scheme.onPrimary : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // عنوان
        Text(
          t(
            context,
            'کلیدی برای گشودن و بازیابی اطلاعات انباشته شده و انبوه',
            'A key to unlocking and retrieving accumulated and massive information',
            'مفتاح لفتح واسترجاع المعلومات المتراكمة والضخمة',
          ),
          style: TextStyle(
            fontSize: titleFont.toDouble(),
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
          textAlign: TextAlign.end,
        ),

        // خط
        Container(
          width: isDesktop ? 200 : isTablet ? 160 : 140,
          height: 4,
          color: underlineColor,
          margin: const EdgeInsets.symmetric(vertical: 12),
        ),

        // متن
        Text(
          t(
            context,
            'اصطلاحات گزیده شده و نظام یافته است که بین آنها روابط معنایی و ردها، یا سلسه مراتبی برقرار است و توانایی آن را دارد که موضوع آن رشته را با تمام جنبه های اصلی، غرعی و وابسته به شکلی نظام یافته و به قصد ذخیره و بازیابی اطلاعات و مدارک و مقاصد جنبی دیگر عرضه کند',
            'It is a selected and systematized set of terms that have semantic relationships and connections, or hierarchies, between them, and has the ability to present the subject of that field with all its main, secondary, and dependent aspects in a systematized form for the purpose of storing and retrieving information, documents, and other ancillary purposes.',
            'هي مجموعة مختارة ومنظمة من المصطلحات التي تربطها علاقات وارتباطات دلالية أو تسلسلات هرمية فيما بينها ولها القدرة على عرض موضوع ذلك المجال بكل جوانبه الرئيسية والثانوية والتابعة بشكل منظم لغرض تخزين واسترجاع المعلومات والوثائق وغيرها من الأغراض المساعدة.',
          ),
          style: TextStyle(
            fontSize: bodyFont.toDouble(),
            color: bodyColor,
            height: 1.6,
          ),
          textAlign: TextAlign.end,
        ),

        const SizedBox(height: 24),

        // دکمه
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBackground,
              foregroundColor: buttonForeground,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 28 : isTablet ? 24 : 20,
                vertical: isDesktop ? 14 : isTablet ? 12 : 12,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: onVideoPressed ?? () {},
            child: Text(
              t(context, 'مشاهده فیلم', 'Watch Video', 'شاهد الفيديو'),
              style: TextStyle(
                fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}