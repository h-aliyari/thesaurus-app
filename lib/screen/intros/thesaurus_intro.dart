import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../service/apis.dart';
import 'feature_block.dart';
import '../../widget/result_cards/thesaurus/thesaurus_page_results.dart';

/// سرویس آمار اصطلاحنامه
Future<Map<String, String>> fetchThesaurusStats() async {
  try {
    final res = await http.get(Uri.parse(ApiUrls.thesaurusStats));
    if (res.statusCode == 200) {
      final body = json.decode(utf8.decode(res.bodyBytes));
      return {
        "term_count": body["term_count"] ?? "-",
        "enc_count": body["enc_count"] ?? "-",
        "domain_count": body["domain_count"] ?? "-",
        "relation_count": body["relation_count"] ?? "-"
      };
    }
  } catch (_) {}
  return {"term_count": "-", "enc_count": "-", "domain_count": "-", "relation_count": "-"};
}

/// سرویس دامنه‌ها
Future<List<Map<String, dynamic>>> fetchDomains() async {
  try {
    final res = await http.get(Uri.parse(ApiUrls.domains));
    if (res.statusCode == 200) {
      final body = json.decode(utf8.decode(res.bodyBytes));
      return List<Map<String, dynamic>>.from(body["data"]).take(12).toList();
    }
  } catch (_) {}
  return [];
}

/// اینترو اصطلاحنامه
Widget buildThesaurusIntro(BuildContext context, String Function(String fa, String en) t) {
  final pad = _dynamicPadding(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      /// بخش اول: کارت‌های آماری
      FutureBuilder<Map<String, String>>(
        future: fetchThesaurusStats(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final s = snap.data ?? {};
          final cards = [
            _buildStatCard("تعداد اصطلاحات", s["term_count"]!, ctx),
            _buildStatCard("تعداد اصطلاحات دارای فرهنگنامه", s["enc_count"]!, ctx),
            _buildStatCard("تعداد دامنه‌ها", s["domain_count"]!, ctx),
            _buildStatCard("تعداد روابط بین اصطلاحات", s["relation_count"]!, ctx),
          ];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: LayoutBuilder(builder: (c, cons) {
              return cons.maxWidth > 600
                  ? Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList())
                  : Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SizedBox(width: MediaQuery.of(context).size.width - pad * 2, child: c))).toList());
            }),
          );
        },
      ),
      const SizedBox(height: 24),

      /// بخش دوم: دامنه‌ها
      Padding(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(t("دامنه‌ها", "Domains"),
              style: const TextStyle(color: Color.fromARGB(255, 106, 126, 136), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDomains(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final domains = snap.data ?? [];
          if (domains.isEmpty) return Text(t("هیچ دامنه‌ای یافت نشد", "No domains found"), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey));

          final w = MediaQuery.of(context).size.width;
          final cols = w >= 1000 ? 6 : w >= 700 ? 4 : 2;
          const spacing = 12.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: LayoutBuilder(builder: (c, cons) {
              final itemWidth = (cons.maxWidth - (cols - 1) * spacing) / cols;
              const targetHeight = 80.0;
              final ratio = itemWidth / targetHeight;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: ratio,
                ),
                itemCount: domains.length,
                itemBuilder: (c, i) {
                  final d = domains[i];
                  final title = d["title"] ?? "";
                  final hex = d["color"];
                  final decoration = hex == null
                      ? const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF47c887), Color(0xFF178775)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.all(Radius.circular(5)))
                      : BoxDecoration(color: Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000), borderRadius: BorderRadius.circular(5));
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ThesaurusResultsPage(
                              query: "*",
                              domainId: d["id"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: decoration,
                        child: Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white))),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
      const SizedBox(height: 24),

      /// بخش سوم: بلاک ویژگی‌ها
      const SizedBox(width: double.infinity, child: ThesaurusFeatureBlock()),
    ],
  );
}

/// کارت آماری
Widget _buildStatCard(String title, String value, BuildContext ctx) {
  final theme = Theme.of(ctx);
  return SizedBox(
    height: 100,
    child: Card(
      elevation: 8,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, width: 0.1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, textAlign: TextAlign.center, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

/// padding داینامیک
double _dynamicPadding(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 1000) return 110;
  if (w >= 700) return 70;
  if (w >= 500) return 40;
  return 16;
}