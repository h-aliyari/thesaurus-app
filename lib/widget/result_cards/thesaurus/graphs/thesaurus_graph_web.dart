import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;
import 'dart:ui_web' as ui;
import '../../../../model/result.dart';
import '../detail/thesaurus_detail.dart';

class ThesaurusGraphWeb extends StatelessWidget {
  final ThesaurusResult result;
  final Map<String, List<dynamic>> relations;
  final Map<String, Color> relationColors;

  const ThesaurusGraphWeb({
    super.key,
    required this.result,
    required this.relations,
    required this.relationColors,
  });

  @override
  Widget build(BuildContext context) {
    final viewType = 'thesaurus-graph-${result.id ?? result.hashCode}';

    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.HTMLIFrameElement()
        ..srcdoc = _graphHtml(result, relations, relationColors)
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'auto';

      return iframe;
    });

    html.window.onMessage.listen((event) {
      try {
        final raw = event.data?.toString();
        if (raw == null) return;

        final data = jsonDecode(raw);

        if (data['type'] == 'node_click') {
          final slug = data['termSlug'] ?? data['termId'].toString();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThesaurusDetailPage(
                slug: slug,
              ),
            ),
          );
        }
      } catch (_) {}
    });

    return Container(
      width: 420,
      height: 420,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ),
      child: HtmlElementView(viewType: viewType),
    );
  }
}

String _graphHtml(
  ThesaurusResult r,
  Map<String, List<dynamic>> relations,
  Map<String, Color> relationColors,
) {
  final nodes = <Map<String, dynamic>>[];
  final edges = <Map<String, dynamic>>[];

  nodes.add({
    'id': r.slug ?? r.id.toString(),
    'label': r.title,
    'shape': 'ellipse',
    'color': {'background': '#a5d6a7', 'border': '#2e7d32'},
    'font': {'color': '#fff', 'face': 'Tahoma'}
  });

  relations.forEach((code, list) {
    final color = relationColors[code] ?? Colors.grey;

    for (var i = 0; i < list.length; i++) {
      final term = list[i]['term'] ?? {};
      final id = term['slug'] ?? term['id'].toString();
      final label = (term['title'] ?? '').toString();
      if (label.isEmpty) continue;

      nodes.add({
        'id': id,
        'label': label,
        'shape': 'ellipse',
        'color': {
          'background': _toHex(color),
          'border': _toHex(color.withOpacity(0.8)),
        },
        'font': {'color': '#fff', 'face': 'Tahoma'}
      });

      edges.add({'from': r.slug ?? r.id.toString(), 'to': id});
    }
  });

  return '''
  <!DOCTYPE html>
  <html dir="rtl">
  <head>
  <meta charset="utf-8" />
  <script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
  <style>
  html,body { margin:0; padding:0; height:100%; overflow:hidden; }
  #mynetwork { width:100%; height:100%; background:transparent; pointer-events:auto; }
  </style>
  </head>
  <body>
    <div id="mynetwork"></div>

    <script>
      var nodes = new vis.DataSet(${jsonEncode(nodes)});
      var edges = new vis.DataSet(${jsonEncode(edges)});
      var container = document.getElementById('mynetwork');

      var network = new vis.Network(container, { nodes: nodes, edges: edges }, {
        physics: true,
        nodes: { shape: 'ellipse', margin: 10 },
        edges: { color: { color: '#999' }, width: 2 }
      });

      network.on("click", function(params) {
        if (params.nodes.length > 0) {
          var nodeId = params.nodes[0];
          var node = nodes.get(nodeId);

          parent.postMessage(JSON.stringify({
            type: "node_click",
            termId: nodeId,
            termSlug: nodeId,
            title: node.label
          }), "*");
        }
      });
    </script>
  </body>
  </html>
  ''';
}

String _toHex(Color c) {
  return '#${c.value.toRadixString(16).substring(2)}';
}