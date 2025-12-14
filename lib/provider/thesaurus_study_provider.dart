import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../service/thesaurus_api.dart';
import '../model/doc_content.dart';

class ThesaurusStudyProvider extends ChangeNotifier {
  // مطالعه
  Map<String, dynamic>? _docDetails;
  List<DocContent> _docContents = [];
  int? _currentDocPageCount;
  List<String> _docTerms = [];

  Map<String, dynamic>? get docDetails => _docDetails;
  List<DocContent> get docContents => _docContents;
  int? get currentDocPageCount => _currentDocPageCount;
  List<String> get docTerms => _docTerms;

  // فیلدهای پنل‌ها
  List<Map<String, dynamic>> _docPageIndexes = [];
  List<Map<String, dynamic>> _docPageTerms = [];

  List<Map<String, dynamic>> get docPageIndexes => _docPageIndexes;
  List<Map<String, dynamic>> get docPageTerms => _docPageTerms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  /// دریافت نمایه‌ها و اصطلاحات صفحه — پارامتر dynamic (int یا String)
  Future<void> fetchDocIndexesTerms(dynamic contentId) async {
    try {
      final resp = await ThesaurusApi.fetchDocIndexesTerms(contentId);

      // raw dynamic
      final dynamic indexesDataRaw = resp['indexes'] ?? [];
      final dynamic termsDataRaw = resp['terms'] ?? [];

      final List<Map<String, dynamic>> indexesList = [];
      if (indexesDataRaw is List) {
        for (final item in indexesDataRaw) {
          if (item is Map<String, dynamic>) {
            indexesList.add(Map<String, dynamic>.from(item));
          } else if (item is Map) {
            indexesList.add(Map<String, dynamic>.from(item.cast<String, dynamic>()));
          }
        }
      }

      final List<Map<String, dynamic>> termsList = [];
      if (termsDataRaw is List) {
        for (final item in termsDataRaw) {
          if (item is Map<String, dynamic>) {
            termsList.add(Map<String, dynamic>.from(item));
          } else if (item is Map) {
            termsList.add(Map<String, dynamic>.from(item.cast<String, dynamic>()));
          }
        }
      }

      _docPageIndexes = indexesList;
      _docPageTerms = termsList;
    } catch (e) {
      _docPageIndexes = [];
      _docPageTerms = [];
    } finally {
      notifyListeners();
    }
  }

  /// دریافت جزئیات سند — پارامتر dynamic (int یا String)
  Future<void> fetchDocDetails(dynamic id) async {
    _setLoading(true);
    try {
      final dynamic rawResult = await ThesaurusApi.getDocDetails(id);
      final Map<String, dynamic>? details =
          rawResult is Map<String, dynamic> ? Map<String, dynamic>.from(rawResult) : null;

      _docDetails = details;

      dynamic rawPage = details != null ? (details['page_count'] ?? details['PageCount']) : null;
      if (details != null && details['doc'] is Map) rawPage = details['doc']['page_count'] ?? rawPage;
      if (details != null && details['doc_details'] is Map) rawPage = details['doc_details']['page_count'] ?? rawPage;
      _currentDocPageCount = _toInt(rawPage);

      _docTerms = [];
      final dynamic rootTerms = details != null ? details['terms'] : null;
      final dynamic docTerms = (details != null && details['doc'] is Map) ? details['doc']['terms'] : null;
      final list = rootTerms is List ? rootTerms : (docTerms is List ? docTerms : []);
      for (final t in list) {
        if (t is Map) {
          final title = t['title'] ?? t['Title'] ?? t['name'];
          if (title != null) _docTerms.add(title.toString());
        } else if (t is String) {
          _docTerms.add(t);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DEBUG[Study] fetchDocDetails error: $e');
      _docDetails = null;
      _currentDocPageCount = null;
      _docTerms = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// دریافت محتوای مطالعه سند — پارامتر dynamic (int یا String)
  Future<void> fetchDocContents(dynamic id) async {
    _setLoading(true);
    try {
      _docContents = await ThesaurusApi.getDocContents(id);
    } catch (e) {
      if (kDebugMode) debugPrint('DEBUG[Study] fetchDocContents error: $e');
      _docContents = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// دریافت هم‌زمان جزئیات و محتوا — پارامتر dynamic (int یا String)
  Future<void> fetchDocWithContents(dynamic id) async {
    _setLoading(true);
    try {
      final dynamic rawResp = await ThesaurusApi.fetchDocWithContents(id);
      final Map<String, dynamic>? respMap =
          rawResp is Map<String, dynamic> ? Map<String, dynamic>.from(rawResp) : null;

      final Map<String, dynamic> docPart = (respMap != null && respMap['doc'] is Map)
          ? Map<String, dynamic>.from(respMap['doc'] as Map)
          : <String, dynamic>{};

      final List<dynamic> contentsPart = (respMap != null && respMap['docContents'] is List)
          ? List<dynamic>.from(respMap['docContents'] as List)
          : <dynamic>[];

      _docDetails = docPart;
      _docContents = contentsPart.map((e) => DocContent.fromJson(e)).toList();

      dynamic rawPage = docPart['page_count'] ?? docPart['PageCount'] ?? docPart['pages_count'];
      if (docPart['doc_details'] is Map) {
        rawPage = docPart['doc_details']['page_count'] ?? rawPage;
      }
      _currentDocPageCount = _toInt(rawPage);

      _docTerms = [];
      final dynamic termsRaw = docPart['terms'];
      if (termsRaw is List) {
        for (final t in termsRaw) {
          if (t is Map) {
            final title = t['title'] ?? t['Title'] ?? t['name'];
            if (title != null) _docTerms.add(title.toString());
          } else if (t is String) {
            _docTerms.add(t);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DEBUG[Study] fetchDocWithContents error: $e');
      _docDetails = null;
      _docContents = [];
      _currentDocPageCount = null;
      _docTerms = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
}
