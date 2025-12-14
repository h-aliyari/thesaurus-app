import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../service/thesaurus_api.dart';
import '../model/result.dart';
import '../model/doc_content.dart';
import '../service/apis.dart';

class ThesaurusProvider extends ChangeNotifier {
  // Locale / direction
  Locale _locale = const Locale('fa');
  TextDirection _direction = TextDirection.rtl;
  Locale get locale => _locale;
  TextDirection get direction => _direction;

  void setLocale(String languageCode, {TextDirection? direction}) {
    _locale = Locale(languageCode);
    _direction = direction ??
        (['fa', 'ar'].contains(languageCode) ? TextDirection.rtl : TextDirection.ltr);
  }

  // --- جستجو و نتایج ---
  final Map<String, List<ThesaurusResult>> _resultsByService = {};
  final Map<String, int> _resultCounts = {};
  String _lastQuery = '';
  String get lastQuery => _lastQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // getters جدید
  Map<String, List<ThesaurusResult>> get byService => _resultsByService;
  Map<String, int> get counts => _resultCounts;
  List<ThesaurusResult> getResults(String label) => _resultsByService[label] ?? [];
  int getCount(String label) => _resultCounts[label] ?? 0;

  Map<String, List<ThesaurusResult>> get resultsByService => _resultsByService;
  Map<String, int> get resultCounts => _resultCounts;
  void clear() => clearSearchState();

  void clearSearchState() {
    _resultsByService.clear();
    _resultCounts.clear();
    _lastQuery = '';
  }

  Future<void> searchAll(String query) async {
    _setLoading(true);
    _lastQuery = query;

    try {
      final lexicon = await ThesaurusApi.fetchPage(query, ApiUrls.lexiconPaged, 1);
      final thesaurus = await ThesaurusApi.fetchPage(query, ApiUrls.thesaurusPaged, 1);
      final index = await ThesaurusApi.fetchPage(query, ApiUrls.indexPaged, 1);
      final resources = await ThesaurusApi.fetchPage(query, ApiUrls.resourcesPaged, 1);

      _resultsByService
        ..clear()
        ..addAll({
          'فرهنگنامه': lexicon.results.take(5).toList(),
          'کتابخانه': resources.results.take(5).toList(),
          'اصطلاحنامه': thesaurus.results.take(5).toList(),
          'نمایه': index.results.take(5).toList(),
        });

      _resultCounts
        ..clear()
        ..addAll({
          'فرهنگنامه': lexicon.total,
          'کتابخانه': resources.total,
          'اصطلاحنامه': thesaurus.total,
          'نمایه': index.total,
        });
        
    } finally {
      _setLoading(false);
    }
  }

  String Function(String, int) _pagedBuilderFor(ThesaurusService service) {
    switch (service) {
      case ThesaurusService.lexicon:
        return ApiUrls.lexiconPaged;
      case ThesaurusService.thesaurus:
        return ApiUrls.thesaurusPaged;
      case ThesaurusService.indexService:
        return ApiUrls.indexPaged;
      case ThesaurusService.resources:
        return ApiUrls.resourcesPaged;
      default:
        return ApiUrls.lexiconPaged;
    }
  }

  Future<void> searchSingle(ThesaurusService service, String label, String query) async {
    _setLoading(true);
    _lastQuery = query;
    try {
      final builder = _pagedBuilderFor(service);
    final page = await ThesaurusApi.fetchPage(query, builder, 1);

    _resultsByService
      ..clear()
      ..[label] = page.results;

    _resultCounts
      ..clear()
      ..[label] = page.total;

    } catch (e) {
      _resultsByService..clear()..[label] = [];
      _resultCounts..clear()..[label] = 0;
    } finally {
      _setLoading(false);
    }
  }

  int? lastDomainId;

  Future<void> searchDomain(String query, int domainId) async {
    _setLoading(true);
    _lastQuery = query;
    lastDomainId = domainId;

    try {
      final results = await ThesaurusApi.searchDomain(query, domainId);

      _resultsByService..clear()..['اصطلاحنامه'] = results;
      _resultCounts..clear()..['اصطلاحنامه'] = results.length;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchAllDomains(String query) async {
    _setLoading(true);
    _lastQuery = query;
    lastDomainId = 0;

    try {
      final results = await ThesaurusApi.searchAllDomains(query);

      _resultsByService..clear()..['اصطلاحنامه'] = results;
      _resultCounts..clear()..['اصطلاحنامه'] = results.length;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLatestDocs() async {
    _setLoading(true);
    try {
      final results = await ThesaurusApi.fetchLatestDocs();
      _resultsByService['جدیدترین منابع'] = results;
      _resultCounts['جدیدترین منابع'] = results.length;
    } catch (e) {
      if (kDebugMode) debugPrint('DEBUG[Provider] fetchLatestDocs error: $e');
      _resultsByService['جدیدترین منابع'] = [];
      _resultCounts['جدیدترین منابع'] = 0;
    } finally {
      _setLoading(false);
    }
  }

  // فیلدهای آخرین جستجو
  String lastTitle = '';
  String lastPublisher = '';
  String lastAuthor = '';
  String lastSubject = '';
  String lastType = '';

  // سرچ پیشرفته
  Future<void> searchAdvanced({
    required String title,
    required String publisher,
    required String author,
    required String subject,
    required String type,
  }) async {
    _setLoading(true);
    try {
      // ذخیره آخرین مقادیر برای استفاده در UI
      lastTitle = title;
      lastPublisher = publisher;
      lastAuthor = author;
      lastSubject = subject;
      lastType = type;

      // ساخت رشته word ترکیبی
      final words = <String>[];
      if (title.isNotEmpty) words.add(title);
      if (publisher.isNotEmpty) words.add(publisher);
      if (author.isNotEmpty) words.add(author);
      if (subject.isNotEmpty) words.add(subject);
      if (type.isNotEmpty && type != '0') words.add(type);

      final queryParams = {
        'word': words.join(' '),
        'page': '1',
      };

      final page = await ThesaurusApi.searchAdvancedDocs(queryParams);

      _resultsByService['کتابخانه'] = page.results;
      _resultCounts['کتابخانه'] = page.total;

    } catch (e) {
      debugPrint('DEBUG[Provider] searchAdvanced error: $e');
      _resultsByService['کتابخانه'] = [];
      _resultCounts['کتابخانه'] = 0;
    } finally {
      _setLoading(false);
    }
  }

  // مطالعه
  Map<String, dynamic>? _docDetails;
  List<DocContent> _docContents = [];
  int? _currentDocPageCount;
  List<String> _docTerms = [];

  Map<String, dynamic>? get docDetails => _docDetails;
  List<DocContent> get docContents => _docContents;
  int? get currentDocPageCount => _currentDocPageCount;
  List<String> get docTerms => _docTerms;

  List<Map<String, dynamic>> _docPageIndexes = [];
  List<Map<String, dynamic>> _docPageTerms = [];

  List<Map<String, dynamic>> get docPageIndexes => _docPageIndexes;
  List<Map<String, dynamic>> get docPageTerms => _docPageTerms;

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  Future<void> fetchDocIndexesTerms(dynamic contentId) async {
    try {
      final resp = await ThesaurusApi.fetchDocIndexesTerms(contentId);
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

      if (kDebugMode) {
        debugPrint('DEBUG[Provider] fetchDocIndexesTerms indexes=${_docPageIndexes.length}, terms=${_docPageTerms.length}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchDocIndexesTerms error: $e');
      _docPageIndexes = [];
      _docPageTerms = [];
    } finally {
    }
  }

  Future<void> fetchDocDetails(dynamic id) async {
    _setLoading(true);
    try {
      final dynamic rawResult = await ThesaurusApi.getDocDetails(id);
      final Map<String, dynamic>? details =
          rawResult is Map<String, dynamic> ? Map<String, dynamic>.from(rawResult) : null;

      _docDetails = details;

      dynamic rawPage = details != null ? (details['page_count'] ?? details['PageCount']) : null;
      if (details != null && details['doc'] is Map) {
        rawPage = details['doc']['page_count'] ?? rawPage;
      }
      if (details != null && details['doc_details'] is Map) {
        rawPage = details['doc_details']['page_count'] ?? rawPage;
      }
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
      if (kDebugMode) debugPrint('fetchDocDetails error: $e');
      _docDetails = null;
      _currentDocPageCount = null;
      _docTerms = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDocContents(dynamic id) async {
    _setLoading(true);
    try {
      _docContents = await ThesaurusApi.getDocContents(id);
    } catch (e) {
      if (kDebugMode) debugPrint('fetchDocContents error: $e');
      _docContents = [];
    } finally {
      _setLoading(false);
    }
  }

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
      if (kDebugMode) debugPrint('fetchDocWithContents error: $e');
      _docDetails = null;
      _docContents = [];
      _currentDocPageCount = null;
      _docTerms = [];
    } finally {
      _setLoading(false);
    }
  }
}