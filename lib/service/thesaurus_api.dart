import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/result.dart';
import '../model/doc_content.dart';
import 'apis.dart';

enum ThesaurusService {
  lexicon,
  thesaurus,
  indexService,
  resources,
  latestDocs,
  stats,
  newIndexed
}

class PageResult {
  final int total;
  final List<ThesaurusResult> results;

  PageResult(this.total, this.results);
}

class ThesaurusPageResult {
  final List<ThesaurusResult> results;
  final int total;

  ThesaurusPageResult({required this.results, required this.total});
}

class ThesaurusApi {
  static const Map<ThesaurusService, String> serviceUrls = {
    ThesaurusService.lexicon: ApiUrls.lexicon,
    ThesaurusService.thesaurus: ApiUrls.thesaurus,
    ThesaurusService.indexService: ApiUrls.indexService,
    ThesaurusService.resources: ApiUrls.resources,
    ThesaurusService.latestDocs: ApiUrls.latestDocs,
    ThesaurusService.stats: ApiUrls.stats,
    ThesaurusService.newIndexed: ApiUrls.newIndexed,
  };

  // سرچ ساده (فقط صفحه ۱)
  static Future<List<ThesaurusResult>> search(
      ThesaurusService service, String query) async {
    final baseUrl = serviceUrls[service];
    if (baseUrl == null || baseUrl.isEmpty) return [];

    final q = Uri.encodeComponent(query);

    final url = (service == ThesaurusService.thesaurus)
        ? '$baseUrl?search_type=5&word=$q&domain=0&page=1'
        : '$baseUrl?word=$q&page=1';

    final page = await fetchPage(query, (q, p) => url, 1);
      return page.results;
  }

  static Future<List<ThesaurusResult>> searchDomain(
  String query, int domainId
  ) async {
    final page = await fetchPage(
      query,
      (q, p) => ApiUrls.thesaurusPagedWithDomain(q, p, domainId),
      1,
    );
    return page.results;
  }

  static Future<List<ThesaurusResult>> searchAllDomains(String query) =>
      search(ThesaurusService.thesaurus, query);

  static Future<List<ThesaurusResult>> fetchLatestDocs() async {
    final page = await fetchPage('', (q, p) => ApiUrls.latestDocs, 1);
    return page.results;
  }

  static Future<Map<String, String>> fetchStats() async {
    try {
      final res = await http.get(Uri.parse(ApiUrls.stats));
      if (res.statusCode != 200) return {};

      final body = json.decode(utf8.decode(res.bodyBytes));

      return {
        "index_count": body["index_count"]?.toString() ?? "-",
        "doc_index_count": body["doc_index_count"]?.toString() ?? "-",
        "term_index_count": body["term_index_count"]?.toString() ?? "-",
      };
    } catch (_) {
      return {};
    }
  }

  static Future<List<ThesaurusResult>> fetchNewIndexed() async {
    final page = await fetchPage('', (q, p) => ApiUrls.newIndexed, 1);
    return page.results;
  }

  // مطالعه
  static String _docDetailsUrl(dynamic id) {
    if (id is int) return ApiUrls.docDetails(id);
    if (id is String) {
      final parsed = int.tryParse(id.trim());
      if (parsed != null) return ApiUrls.docDetails(parsed);
    }
    return ApiUrls.docDetailsAny(id.toString());
  }

  static String _docReadUrl(dynamic id) {
    if (id is int) return ApiUrls.docRead(id);
    if (id is String) {
      final parsed = int.tryParse(id.trim());
      if (parsed != null) return ApiUrls.docRead(parsed);
    }
    return ApiUrls.docReadAny(id.toString());
  }

  static String _docIndexesTermsUrl(dynamic contentId) {
    if (contentId is int) return ApiUrls.docIndexesTerms(contentId);
    if (contentId is String) {
      final parsed = int.tryParse(contentId.trim());
      if (parsed != null) return ApiUrls.docIndexesTerms(parsed);
    }
    return ApiUrls.docIndexesTermsAny(contentId.toString());
  }

  static Future<Map<String, dynamic>> getDocDetails(dynamic id) async {
    try {
      final url = _docDetailsUrl(id);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return {};

      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body is! Map<String, dynamic>) return {};

      final mapBody = Map<String, dynamic>.from(body);

      final doc = mapBody['doc'];
      final hasRootDetails =
          mapBody['details'] is List && (mapBody['details'] as List).isNotEmpty;
      final docHasDetails =
          doc is Map && doc['details'] is List && (doc['details'] as List).isNotEmpty;

      if (!hasRootDetails && docHasDetails) {
        mapBody['details'] = List<dynamic>.from(doc['details'] as List);
      }

      return mapBody;
    } catch (_) {
      return {};
    }
  }

  static Future<List<DocContent>> getDocContents(dynamic id) async {
    try {
      final url = _docReadUrl(id);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return [];

      final body = json.decode(utf8.decode(res.bodyBytes));
      final data = body is Map<String, dynamic>
          ? (body['docContents'] ?? body['data'])
          : body;

      if (data is! List) return [];

      return data.map((e) {
        final map = e is Map<String, dynamic>
            ? Map<String, dynamic>.from(e)
            : <String, dynamic>{};
        return DocContent.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> fetchDocWithContents(dynamic id) async {
    try {
      final detailsUrl = _docDetailsUrl(id);
      final detailsResp = await http.get(Uri.parse(detailsUrl));

      Map<String, dynamic> docPart = {};
      if (detailsResp.statusCode == 200) {
        final body = json.decode(utf8.decode(detailsResp.bodyBytes));
        if (body is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(body);
          docPart = map.containsKey('doc') && map['doc'] is Map
              ? Map<String, dynamic>.from(map['doc'])
              : map;

          if (map['terms'] is List) {
            docPart['terms'] = List<dynamic>.from(map['terms']);
          } else if (map['doc'] is Map && map['doc']['terms'] is List) {
            docPart['terms'] = List<dynamic>.from(map['doc']['terms']);
          }
        }
      }

      final contentsUrl = _docReadUrl(id);
      final contentsResp = await http.get(Uri.parse(contentsUrl));

      List<dynamic> contentsList = [];
      if (contentsResp.statusCode == 200) {
        final body = json.decode(utf8.decode(contentsResp.bodyBytes));
        final data = body is Map<String, dynamic>
            ? (body['docContents'] ?? body['data'])
            : body;
        if (data is List) contentsList = data;
      }

      return {'doc': docPart, 'docContents': contentsList};
    } catch (_) {
      return {'doc': {}, 'docContents': []};
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> fetchDocIndexesTerms(
      dynamic contentId) async {
    try {
      final url = _docIndexesTermsUrl(contentId);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return {'indexes': [], 'terms': []};

      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body is! Map<String, dynamic>) return {'indexes': [], 'terms': []};

      final mapBody = Map<String, dynamic>.from(body);

      final indexesRaw = mapBody['indexes'] is Map
          ? (mapBody['indexes']['data'] ?? [])
          : (mapBody['indexes'] ?? []);

      final termsRaw = mapBody['terms'] is Map
          ? (mapBody['terms']['data'] ?? [])
          : (mapBody['terms'] ?? []);

      final indexesList = <Map<String, dynamic>>[];
      if (indexesRaw is List) {
        for (final item in indexesRaw) {
          if (item is Map<String, dynamic>) {
            indexesList.add(Map<String, dynamic>.from(item));
          }
        }
      }

      final termsList = <Map<String, dynamic>>[];
      if (termsRaw is List) {
        for (final item in termsRaw) {
          if (item is Map<String, dynamic>) {
            termsList.add(Map<String, dynamic>.from(item));
          }
        }
      }

      return {'indexes': indexesList, 'terms': termsList};
    } catch (_) {
      return {'indexes': [], 'terms': []};
    }
  }

  // سرچ پیشرفته کتابخانه
  static Future<PageResult> searchAdvancedDocs(Map<String, String> queryParams) async {
    try {
      // ساخت URL با همه پارامترها
      final uri = Uri.parse(ApiUrls.resources).replace(queryParameters: {
        'word': queryParams['word'] ?? '',
        'page': queryParams['page'] ?? '1',
        'publisher': queryParams['publisher'] ?? '',
        'author': queryParams['author'] ?? '',
        'subject': queryParams['subject'] ?? '',
        'type': queryParams['type'] ?? '0',
      });

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        // گرفتن لیست نتایج
        final resultsRaw = body['data'] as List<dynamic>? ?? [];
          final results = resultsRaw
              .whereType<Map<String, dynamic>>()
              .map((e) => ThesaurusResult.fromJson(e))
              .toList();

        // گرفتن تعداد کل
        int total = 0;
          if (body['meta'] is Map &&
              (body['meta']['pagination'] is Map) &&
              (body['meta']['pagination']['total'] != null)) {
            total = body['meta']['pagination']['total'] as int;
          }

        return PageResult(total, results);
      } else {
        throw Exception("searchAdvancedDocs failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("DEBUG[Api] searchAdvancedDocs error=$e");
      return PageResult(0, []);
    }
  }

  // صفحه‌بندی کامل برای صفحهٔ Home
  static Future<Map<String, dynamic>> fetchAllPagesForHome(
    String query,
    String Function(String, int) apiBuilder,
  ) async {
    final List<ThesaurusResult> all = [];
    int total = 0;

    try {
      int page = 1;

      while (true) {
        final url = apiBuilder(query, page);
        final response = await http.get(Uri.parse(url));

        if (response.statusCode != 200) {
          break;
        }

        final decoded = json.decode(utf8.decode(response.bodyBytes));

        // total فقط صفحه اول
        if (page == 1 &&
            decoded is Map<String, dynamic> &&
            decoded['meta'] is Map &&
            (decoded['meta'] as Map)['pagination'] is Map &&
            ((decoded['meta'] as Map)['pagination'] as Map)['total'] is int) {
          total = ((decoded['meta'] as Map)['pagination'] as Map)['total'] as int;
        }

        // استخراج data
        List<dynamic> data = [];

        if (decoded is Map<String, dynamic>) {
          final map = decoded;

          if (map['data'] is List) {
            data = map['data'];
          } else if (map['docs'] is List) {
            data = map['docs'];
          } else if (map['results'] is List) {
            data = map['results'];
          }
        }

        if (data.isEmpty) {
          break;
        }

        for (final item in data) {
          if (item is Map<String, dynamic>) {
            all.add(ThesaurusResult.fromJson(Map<String, dynamic>.from(item)));
          }
        }

        // meta / pagination
        Map<String, dynamic>? pagination;

        if (decoded is Map<String, dynamic>) {
          final meta = decoded['meta'];
          if (meta is Map<String, dynamic>) {
            final pag = meta['pagination'];
            if (pag is Map<String, dynamic>) {
              pagination = pag;
            }
          }
        }

        if (pagination == null) {
          break;
        }

        int totalPages = 1;
        final tp = pagination['total_pages'];
        if (tp is int) {
          totalPages = tp;
        }

        if (page >= totalPages) {
          break;
        }

        final links = pagination['links'];
        if (links is! Map || links['next'] == null) {
          break;
        }

        page++;
      }
    } catch (_) {}

    return {
      "total": total,
      "results": all,
    };
  }


  static Future<PageResult> fetchPage(
    String query,
    String Function(String, int) apiBuilder,
    int page,
  ) async {
    final url = apiBuilder(query, page);

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      return PageResult(0, <ThesaurusResult>[]);
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      return PageResult(0, <ThesaurusResult>[]);
    }

    // total
    int total = 0;
    final meta = decoded['meta'];
    if (meta is Map<String, dynamic>) {
      final pagination = meta['pagination'];
      if (pagination is Map<String, dynamic>) {
        final t = pagination['total'];
        if (t is int) total = t;
      }
    }

    // data
    final raw = decoded['data'];
    if (raw is! List) {
      return PageResult(total, <ThesaurusResult>[]);
    }

    // تبدیل امن به List<ThesaurusResult>
    final List<ThesaurusResult> results = raw
        .whereType<Map<String, dynamic>>()
        .map((e) => ThesaurusResult.fromJson(e))
        .toList(growable: false);

    return PageResult(total, results);
  }

  static Future<ThesaurusPageResult> fetchThesaurusPage(
    String query,
    int page, {
    int domainId = 0,
  }) async {
    final url = ApiUrls.thesaurusPagedWithDomain(query, page, domainId);
    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      return ThesaurusPageResult(results: [], total: 0);
    }

    final body = jsonDecode(res.body);

    final List<dynamic> items = body['data'] ?? [];
    final total = body['meta']?['pagination']?['total'] ?? 0;

    final results = items
        .whereType<Map<String, dynamic>>()
        .map((e) => ThesaurusResult.fromJson(e))
        .toList();

    return ThesaurusPageResult(results: results, total: total);
  }
}