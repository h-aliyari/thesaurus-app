import 'package:flutter/material.dart';
import 'feature_block.dart';
import '../base_screen.dart';
import '../../../model/result.dart';
import '../../widget/result_cards/library/library_card.dart';
import '../../service/thesaurus_api.dart';

double _dynamicPadding(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 600) return 12; // موبایل
  if (w < 1024) return 40; // تبلت
  return 110; // دسکتاپ
}

/// بخش اول: کارت‌های آماری
class IndexStatsBlock extends StatefulWidget {
  final String Function(String fa, String en) t;
  const IndexStatsBlock({super.key, required this.t});

  @override
  State<IndexStatsBlock> createState() => _IndexStatsBlockState();
}

class _IndexStatsBlockState extends State<IndexStatsBlock> {
  String indexCount = "-", docIndexCount = "-", termIndexCount = "-";

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final data = await ThesaurusApi.fetchStats();
    setState(() {
      indexCount = data["index_count"] ?? "-";
      docIndexCount = data["doc_index_count"] ?? "-";
      termIndexCount = data["term_index_count"] ?? "-";
    });
  }

  Widget buildCard(String title, String value, BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 100,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
            width: 0.1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(value,
                  style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      buildCard(widget.t("تعداد نمایه‌ها", "Index Count"), indexCount, context),
      buildCard(widget.t("تعداد منابع نمایه‌شده", "Doc Index Count"), docIndexCount, context),
      buildCard(widget.t("تعداد اصطلاحات", "Term Index Count"), termIndexCount, context),
    ];
    final pad = _dynamicPadding(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return isWide
            ? Row(children: cards.map((c) => Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: c,
                ))).toList())
            : Column(children: cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - pad * 2,
                    child: c,
                  ),
                )).toList());
      }),
    );
  }
}

/// بخش دوم: جدیدترین کتب نمایه شده
class NewIndexedBlock extends StatefulWidget {
  final String Function(String fa, String en) t;
  const NewIndexedBlock({super.key, required this.t});

  @override
  State<NewIndexedBlock> createState() => _NewIndexedBlockState();
}

class _NewIndexedBlockState extends State<NewIndexedBlock> {
  List<ThesaurusResult> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await ThesaurusApi.fetchNewIndexed();
    setState(() => items = data);
  }

  @override
  Widget build(BuildContext context) {
    final pad = _dynamicPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(widget.t("جدیدترین کتب نمایه شده", "Latest Indexed Books"),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(width: 250, child: LibraryCard(result: items[i])),
            ),
          ),
        ],
      ),
    );
  }
}

/// Intro کامل
Widget buildIndexIntro(String Function(String fa, String en) t) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      IndexStatsBlock(t: t),
      const SizedBox(height: 30),
      NewIndexedBlock(t: t),
      const SizedBox(height: 16),
      const FullWidthWidget(child: ThesaurusFeatureBlock()),
    ],
  );
}