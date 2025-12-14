import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../model/result.dart';
import '../../../../../service/apis.dart';
import 'package:go_router/go_router.dart';

class ThesaurusDetailTree extends StatefulWidget {
  final ThesaurusResult result;

  const ThesaurusDetailTree({super.key, required this.result});

  @override
  State<ThesaurusDetailTree> createState() => _ThesaurusDetailTreeState();
}

class _ThesaurusDetailTreeState extends State<ThesaurusDetailTree> {
  List<TreeNode> roots = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTree();
  }

  Future<void> _fetchTree() async {
    final treeId = widget.result.id;

    if (treeId == null || treeId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    final url = ApiUrls.thesaurusTree(treeId);

    try {
      final res = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() => loading = false);
        return;
      }

      final body = jsonDecode(res.body);

      if (body['data'] == null || body['data'] is! List) {
        setState(() => loading = false);
        return;
      }

      final List<dynamic> data = body['data'];

      setState(() {
        roots = data.map((e) => TreeNode.fromJson(e)).toList();
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (roots.isEmpty) {
      return const Center(
        child: Text(
          "درختواره‌ای موجود نیست",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: roots.map((node) => TreeNodeWidget(node: node)).toList(),
    );
  }
}

// مدل TreeNode
class TreeNode {
  final String id;
  final String title;
  bool expanded;
  final List<TreeNode> children;

  TreeNode({
    required this.id,
    required this.title,
    this.expanded = false,
    this.children = const [],
  });

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      expanded: json['expanded'] ?? false,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => TreeNode.fromJson(c))
          .toList(),
    );
  }
}

// ویجت بازگشتی TreeNodeWidget
class TreeNodeWidget extends StatefulWidget {
  final TreeNode node;
  final double indent;

  const TreeNodeWidget({
    super.key,
    required this.node,
    this.indent = 0,
  });

  @override
  State<TreeNodeWidget> createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends State<TreeNodeWidget> {
  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Padding(
          padding: EdgeInsets.only(right: widget.indent),
          child: InkWell(
            onTap: () {
              // رفتن به دیتیل اصطلاحنامه
              context.push(
                '/thesaurus/detail/${node.id}',
                extra: ThesaurusResult.fromJson({
                  "id": node.id,
                  "title": node.title,
                  "slug": node.id,
                }),
              );
            },
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // آیکون باز/بسته
                if (node.children.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() => node.expanded = !node.expanded);
                    },
                    child: Icon(
                      node.expanded
                          ? Icons.arrow_drop_down
                          : Icons.arrow_left,
                      size: 22,
                    ),
                  )
                else
                  const SizedBox(width: 22),

                // عنوان
                Expanded(
                  child: Text(
                    node.title,
                    style: const TextStyle(fontSize: 14),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ),

        // نمایش بچه‌ها
        if (node.expanded)
          ...node.children.map(
            (child) => TreeNodeWidget(
              node: child,
              indent: widget.indent + 24,
            ),
          ),
      ],
    );
  }
}