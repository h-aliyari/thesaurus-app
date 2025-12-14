import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../model/result.dart';
import 'thesaurus_graph_web.dart';
import 'thesaurus_graph_native.dart';

class ThesaurusGraph extends StatelessWidget {
  final ThesaurusResult result;
  final Map<String, List<dynamic>> relations;
  final Map<String, Color> relationColors;

  const ThesaurusGraph({
    super.key,
    required this.result,
    required this.relations,
    required this.relationColors,
  });

  @override
  Widget build(BuildContext context) {
    try {
      if (kIsWeb) {
        return ThesaurusGraphWeb(
          result: result,
          relations: relations,
          relationColors: relationColors,
        );
      }

      return ThesaurusGraphNative(
        result: result,
        relations: relations,
        relationColors: relationColors,
      );
    } catch (e) {
      debugPrint("Graph error inside ThesaurusGraph: $e");
      return const Center(child: Text("گراف اصطلاحنامه"));
    }
  }
}