import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../model/result.dart';

class LibraryGraphNative extends StatelessWidget {
  final ThesaurusResult result;
  final List<String> terms;

  const LibraryGraphNative({super.key, required this.result, this.terms = const []});

  @override
  Widget build(BuildContext context) {
    try {
      final controller = WebViewController();
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) {
            final nodes = _buildVisNodes(result, terms);
            final edges = _buildVisEdges(result, terms);
            controller.runJavaScript('renderGraph($nodes, $edges);');
          },
          onWebResourceError: (err) => debugPrint("Graph load error: ${err.description}"),
        ))
        ..loadHtmlString(_graphHtml);
      return WebViewWidget(controller: controller);
    } catch (e) {
      debugPrint("Graph error inside LibraryGraphNative: $e");
      return const Center(child: Text("گراف"));
    }
  }
}

const String _graphHtml = '''
<!DOCTYPE html><html dir="rtl"><head><meta charset="utf-8"/><script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>html,body{margin:0;padding:0;height:100%;overflow:hidden}#mynetwork{width:100%;height:100%;background:transparent}</style>
</head><body><div id="mynetwork"></div><script>
function renderGraph(nodesJson, edgesJson) {
  var nodes = new vis.DataSet(nodesJson);
  var edges = new vis.DataSet(edgesJson);
  var container = document.getElementById('mynetwork');
  var data = { nodes: nodes, edges: edges };
  var options = {
    physics: true,
    nodes: { shape: 'ellipse', font: { color: '#000', face: 'Tahoma', align: 'center' }, margin: 10 },
    edges: { color: { color: '#999' }, width: 2, font: { align: 'middle', face: 'Tahoma' } }
  };
  new vis.Network(container, data, options);
}
</script></body></html>
''';

String _buildVisNodes(ThesaurusResult r, List<String> terms) {
  final nodes = <Map<String, dynamic>>[];
  nodes.add({'id':'center','label': r.title.isEmpty ? 'بدون عنوان' : r.title, 'shape':'ellipse','color':{'background':'#a5d6a7','border':'#2e7d32'},'font':{'color':'#000','face':'Tahoma'}});
  void add(String id, String label, String bg, String border) => nodes.add({'id':id,'label':label,'shape':'ellipse','color':{'background':bg,'border':border},'font':{'color':'#000','face':'Tahoma'}});
  if (r.type?.trim().isNotEmpty ?? false) add('type', r.type!, '#d7ccc8', '#6d4c41');
  if (r.publisher?.trim().isNotEmpty ?? false) add('publisher', r.publisher!, '#f8bbd0', '#ad1457');
  if (r.author?.trim().isNotEmpty ?? false) add('author', r.author!, '#bbdefb', '#1565c0');
  if (r.abstractText?.trim().isNotEmpty ?? false) add('abstract', r.abstractText!, '#e1bee7', '#5e35b1');
  if (r.publishDate?.trim().isNotEmpty ?? false) add('publish_date', r.publishDate!, '#b2ebf2', '#00838f');

  for (var i = 0; i < terms.length; i++) {
    final id = 'term_$i';
    final label = terms[i].trim().isEmpty ? 'اصطلاح' : terms[i];
    add(id, label, '#fff9c4', '#f9a825');
  }

  if (nodes.length == 1) add('info', 'اطلاعات بیشتر موجود نیست', '#eeeeee', '#9e9e9e');
  return jsonEncode(nodes);
}

String _buildVisEdges(ThesaurusResult r, List<String> terms) {
  final edges = <Map<String, dynamic>>[];
  void e(String from, String to, String label) => edges.add({'from':from,'to':to,'label':label});
  if (r.type?.trim().isNotEmpty ?? false) e('center','type','نوع');
  if (r.publisher?.trim().isNotEmpty ?? false) e('center','publisher','ناشر');
  if (r.author?.trim().isNotEmpty ?? false) e('center','author','نویسنده');
  if (r.abstractText?.trim().isNotEmpty ?? false) e('center','abstract','چکیده');
  if (r.publishDate?.trim().isNotEmpty ?? false) e('center','publish_date','تاریخ انتشار');
  for (var i = 0; i < terms.length; i++) e('center','term_$i','اصطلاح');
  return jsonEncode(edges);
}