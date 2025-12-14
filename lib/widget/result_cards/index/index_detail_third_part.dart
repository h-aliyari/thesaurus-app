import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../model/result.dart';
import '../library/library_detail.dart';
import '../../../service/apis.dart';

/// بخش سوم: کتاب
class IndexDetailBook extends StatefulWidget {
  final ThesaurusResult result;
  const IndexDetailBook({super.key, required this.result});

  @override
  State<IndexDetailBook> createState() => _IndexDetailBookState();
}

class _IndexDetailBookState extends State<IndexDetailBook> {
  bool loading = true;
  Map<String, dynamic>? bookData;

  @override
  void initState() {
    super.initState();
    _fetchBookDetail();
  }

  Future<void> _fetchBookDetail() async {
    final id = widget.result.bookId;
    if (id == null) {
      setState(() => loading = false);
      return;
    }

    final url = ApiUrls.docDetails(int.parse(id));
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        debugPrint("Book detail response: $data");
        setState(() {
          bookData = data;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error fetching book detail: $e");
      setState(() => loading = false);
    }
  }

  @override
    Widget build(BuildContext context) {
      if (loading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (bookData == null) {
        return const Scaffold(
          body: Center(child: Text("اطلاعات کتاب یافت نشد")),
        );
      }

      return Scaffold(
        body: LibraryDetailPage(
          result: ThesaurusResult.fromJson(bookData!),
        ),
      );
    }
}