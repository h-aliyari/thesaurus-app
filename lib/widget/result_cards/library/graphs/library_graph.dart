import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../model/result.dart';
import 'library_graph_web.dart';
import 'library_graph_native.dart';

class LibraryGraph extends StatelessWidget {
  final ThesaurusResult result;
  final List<String> terms;

  const LibraryGraph({super.key, required this.result, this.terms = const []});

  @override
  Widget build(BuildContext context) {
    try {
      if (kIsWeb) return LibraryGraphWeb(result: result, terms: terms);
      return LibraryGraphNative(result: result, terms: terms);
    } catch (e) {
      debugPrint("Graph error inside LibraryGraph: $e");
      return const Center(child: Text("گراف"));
    }
  }
}