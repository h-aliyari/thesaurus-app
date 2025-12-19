import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;
import 'dart:ui_web' as ui;
import '../../../../model/result.dart';

class LibraryGraphWeb extends StatelessWidget {
  final ThesaurusResult result;
  final List<String> terms;

  const LibraryGraphWeb({super.key, required this.result, this.terms = const []});

  @override
  Widget build(BuildContext context) {
    try {
      final viewType = 'graph-iframe-${result.id ?? ''}-${DateTime.now().microsecondsSinceEpoch}';

      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final iframe = html.HTMLIFrameElement()
          ..srcdoc = _graphHtml(result, terms)
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });

      return HtmlElementView(viewType: viewType);
    } catch (e) {
      debugPrint("Graph error inside LibraryGraphWeb: $e");
      return const Center(child: Text("گراف"));
    }
  }
}

String _graphHtml(ThesaurusResult r, List<String> terms) {
  final nodes = _buildVisNodes(r, terms);
  final edges = _buildVisEdges(r, terms);

  return '''
<!DOCTYPE html>
<html dir="rtl">
<head>
<meta charset="utf-8" />
<script src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
<style>
html,body{margin:0;padding:0;height:100%;overflow:hidden}
#mynetwork{width:100%;height:100%;background:transparent}
</style>
</head>
<body>
<div id="mynetwork"></div>

<script>
var nodes = new vis.DataSet($nodes);
var edges = new vis.DataSet($edges);

var container = document.getElementById('mynetwork');
var data = { nodes: nodes, edges: edges };

var options = {
  physics: true,
  nodes: {
    shape: 'ellipse',
    font: { color: '#000', face: 'Tahoma', align: 'center' },
    margin: 10
  },
  edges: {
    color: { color: '#999' },
    width: 2,
    arrows: { to: { enabled: true, scaleFactor: 0.7 } }
  }
};

var network = new vis.Network(container, data, options);

// کلیک روی نود اصطلاح
network.on("click", function (params) {
  if (params.nodes.length > 0) {
    var id = params.nodes[0];
    if (id.startsWith("term_")) {
      var slug = id.replace("term_", "");
      window.parent.postMessage(JSON.stringify({ type: "openTerm", slug: slug }), "*");
    }
  }
});
</script>

</body>
</html>
''';
}

String _buildVisNodes(ThesaurusResult r, List<String> terms) {
  final nodes = <Map<String, dynamic>>[];

  nodes.add({
    'id': 'center',
    'label': r.title.isEmpty ? 'بدون عنوان' : r.title,
    'shape': 'ellipse',
    'color': {'background': '#a5d6a7', 'border': '#2e7d32'},
    'font': {'color': '#000', 'face': 'Tahoma'}
  });

  for (var i = 0; i < terms.length; i++) {
    nodes.add({
      'id': 'term_$i',
      'label': terms[i],
      'shape': 'ellipse',
      'color': {'background': '#fff9c4', 'border': '#f9a825'},
      'font': {'color': '#000', 'face': 'Tahoma'}
    });
  }

  return jsonEncode(nodes);
}

String _buildVisEdges(ThesaurusResult r, List<String> terms) {
  final edges = <Map<String, dynamic>>[];

  for (var i = 0; i < terms.length; i++) {
    edges.add({
      'from': 'center',
      'to': 'term_$i',
      'arrows': 'to'
    });
  }

  return jsonEncode(edges);
}
