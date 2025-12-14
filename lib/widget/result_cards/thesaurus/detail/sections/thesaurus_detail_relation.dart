import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../model/result.dart';
import '../../../../../service/apis.dart';
import '../../graphs/thesaurus_graph.dart';
import '../thesaurus_detail.dart';

class ThesaurusDetailRelation extends StatefulWidget {
  final ThesaurusResult result;

  const ThesaurusDetailRelation({
    super.key,
    required this.result,
  });

  @override
  State<ThesaurusDetailRelation> createState() => _ThesaurusDetailRelationState();
}

class _ThesaurusDetailRelationState extends State<ThesaurusDetailRelation> {
  Map<String, List<dynamic>> relations = {};
  bool loading = true;

  final relationColors = {
    'am': Colors.green,
    'bek': Colors.orange,
    'bej': Colors.red,
    'akh': Colors.blue,
    'av': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final slugOrId = widget.result.slug ?? widget.result.id;
    if (slugOrId == null || slugOrId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    final url = '${ApiUrls.thesaurus}/$slugOrId';

    try {
      final res = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = (body['data'] ?? {}) as Map<String, dynamic>;

        setState(() {
          relations = {
            'am': (data['am']?['data'] ?? []),
            'bek': (data['bek']?['data'] ?? []),
            'bej': (data['bej']?['data'] ?? []),
            'akh': (data['akh']?['data'] ?? []),
            'av': (data['av']?['data'] ?? []),
          };
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Widget relationItem(dynamic item) {
    final term = item['term'] ?? {};
    final title = (term['title'] ?? '').toString();
    if (title.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ThesaurusDetailPage(
              slug: term['slug'] ?? term['id'].toString(),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget relationSection(String code, String label, Color color, List<dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final Map<String, List<dynamic>> groups = {};

    for (var item in data) {
      final p = (item['perspective'] ?? '').toString().trim();
      final key = p.isEmpty ? '_no_perspective_' : p;
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$code = $label',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...groups.entries.map((entry) {
          final perspective = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (perspective != '_no_perspective_') ...[
                Text(
                  '(به لحاظ : $perspective)',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              ...items.map((item) => relationItem(item)).toList(),
              const SizedBox(height: 14),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget relationsBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        relationSection('ا.ع', 'اصطلاح(های) اعم', relationColors['am']!, relations['am'] ?? []),
        relationSection('بک', 'مترادف(های) مرجح', relationColors['bek']!, relations['bek'] ?? []),
        relationSection('بج', 'مترادف(های) نامرجح', relationColors['bej']!, relations['bej'] ?? []),
        relationSection('ا.خ', 'اصطلاح(های) اخص', relationColors['akh']!, relations['akh'] ?? []),
        relationSection('ا.و', 'اصطلاح(های) وابسته', relationColors['av']!, relations['av'] ?? []),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasRelations = relations.values.any((list) => list.isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // موبایل
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              relationsBox(),
              const SizedBox(height: 20),

              if (hasRelations)
                ThesaurusGraph(
                  result: widget.result,
                  relations: relations,
                  relationColors: relationColors,
                ),
            ],
          );
        }

        // دسکتاپ
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasRelations)
              Expanded(
                flex: 5,
                child: ThesaurusGraph(
                  result: widget.result,
                  relations: relations,
                  relationColors: relationColors,
                ),
              ),

            const SizedBox(width: 24),

            Expanded(
              flex: 2,
              child: relationsBox(),
            ),
          ],
        );
      },
    );
  }
}