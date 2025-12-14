class ThesaurusResult {
  final Map<String, dynamic> raw;
  final Map<String, dynamic> data;

  ThesaurusResult._(this.raw, this.data);

  factory ThesaurusResult.fromJson(Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json);

    final merged = Map<String, dynamic>.from(raw);
    if (json.containsKey('doc') && json['doc'] is Map<String, dynamic>) {
      final docMap = Map<String, dynamic>.from(json['doc']);
      merged.addAll(docMap);

      if (docMap['details'] != null) merged['details'] = docMap['details'];
    }

    if (json['details'] != null) merged['details'] = json['details'];

    return ThesaurusResult._(raw, merged);
  }

  // Helpers
  String _clean(dynamic s) {
    if (s == null) return '';
    final str = s.toString();
    return str.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  String _pickFirstString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString();
      if (s.trim().isNotEmpty) return s.trim();
    }
    return '';
  }

  // دسترسی مستقیم برای دیباگ
  Map<String, dynamic> get rawData => raw;
  Map<String, dynamic> get mergedData => data;

  // فیلدهای عمومی
  String get title {
    final t = _pickFirstString([
      raw['title'],
      raw['Title'],
      data['title'],
      data['Title'],
      data['SimpleTitle'],
      data['name'],
      data['word'],
      data['Word'],
    ]);

    if (t.isNotEmpty) return _clean(t);

    final slug = (data['slug'] ?? data['Slug'])?.toString() ?? '';
    if (slug.isNotEmpty) {
      final i = slug.indexOf('-');
      if (i >= 0 && i + 1 < slug.length) return _clean(slug.substring(i + 1));
      return _clean(slug);
    }
    return '';
  }

  String? get description {
    final d = _pickFirstString([
      data['Description'],
      data['description'],
      data['text'],
      data['body'],
      raw['Description'],
      raw['description'],
      raw['text']
    ]);
    return _clean(d).isNotEmpty ? _clean(d) : null;
  }

  String? get abstractText {
    final a = _pickFirstString([data['Abstract'], data['abstract'], data['Description'], data['description']]);
    return _clean(a).isNotEmpty ? _clean(a) : null;
  }

  String? get reference {
    final r = _pickFirstString([data['Reference'], data['reference'], raw['Reference'], raw['reference']]);
    return _clean(r).isNotEmpty ? _clean(r) : null;
  }

  String? get status {
    final s = _pickFirstString([raw['status'], raw['Status'], data['status'], data['Status'],]);
    return _clean(s).isNotEmpty ? _clean(s) : null;
  }

  String? get pref {
    final p = _pickFirstString([data['Pref'], data['pref'], raw['Pref'], raw['pref']]);
    return _clean(p).isNotEmpty ? _clean(p) : null;
  }

  String? get domain {
    final d = _pickFirstString([raw['domain'], raw['Domain'], data['domain'], data['Domain'],]);
    return _clean(d).isNotEmpty ? _clean(d) : null;
  }

  String? get publisher {
    final p = _pickFirstString([data['publisher'], data['Publisher'], data['PublishLocation'], data['publisher_name']]);
    return _clean(p).isNotEmpty ? _clean(p) : null;
  }

  String? get author {
    final a = _pickFirstString([data['author'], data['Author'], data['Creator'], data['writer']]);
    return _clean(a).isNotEmpty ? _clean(a) : null;
  }

  String? get publishDate {
    final p = _pickFirstString([data['publish_date'], data['PublishDate'], data['date'], data['created_at']]);
    return _clean(p).isNotEmpty ? _clean(p) : null;
  }

  String? get type {
    final t = _pickFirstString([data['type'], data['Type'], data['DocType'], data['DocTypeId']]);
    return _clean(t).isNotEmpty ? _clean(t) : null;
  }

  String? get id {
    final v = _pickFirstString([data['id'], data['Id'], data['DocId'], raw['id'], raw['DocId']]);
    return _clean(v).isNotEmpty ? _clean(v) : null;
  }

  String? get slug {
    final s = _pickFirstString([data['slug'], data['Slug']]);
    return _clean(s).isNotEmpty ? _clean(s) : null;
  }

  int? get relationsCount =>
    _toInt(raw['relations_count'] ?? data['relations_count']);

  int? get indexesCount =>
    _toInt(raw['indexes_count'] ?? data['indexes_count']);

  // نمایه (doc_details) — سازگار با کارت IndexCard
  Map<String, dynamic>? get docDetails {
    final candidate = data['doc_details'] ?? data['docDetails'] ?? raw['doc_details'] ?? raw['doc'];
    if (candidate is Map<String, dynamic>) return candidate;
    return null;
  }

  String? get book => _clean(docDetails?['title']?.toString()).isNotEmpty ? _clean(docDetails?['title']?.toString()) : null;
  String? get bookId => _clean(docDetails?['id']?.toString()).isNotEmpty ? _clean(docDetails?['id']?.toString()) : null;
  String? get bookTitle => book;
  String? get bookType => _clean(docDetails?['type']?.toString()).isNotEmpty ? _clean(docDetails?['type']?.toString()) : null;
  String? get bookAbstract => _clean(docDetails?['abstract']?.toString()).isNotEmpty ? _clean(docDetails?['abstract']?.toString()) : null;
  String? get bookPublisher => _clean(docDetails?['publisher']?.toString()).isNotEmpty ? _clean(docDetails?['publisher']?.toString()) : null;
  String? get bookAuthor => _clean(docDetails?['author']?.toString()).isNotEmpty ? _clean(docDetails?['author']?.toString()) : null;
  String? get bookPublishDate => _clean(docDetails?['publish_date']?.toString()).isNotEmpty ? _clean(docDetails?['publish_date']?.toString()) : null;
  String? get bookDescription => _clean(docDetails?['description']?.toString()).isNotEmpty ? _clean(docDetails?['description']?.toString()) : null;

  List<dynamic> get bookRelations {
    final r = docDetails?['relations'] ?? data['relations'] ?? raw['relations'];
    if (r is List) return r;
    return [];
  }

  /// استخراج اصطلاحات/terms به صورت لیست رشته‌ای
  List<String> get terms {
    final rels = docDetails?['relations'] ?? data['relations'] ?? raw['terms'] ?? raw['terms_list'];
    if (rels is List) {
      final out = <String>[];
      for (final r in rels) {
        if (r is Map) {
          final t = _pickFirstString([r['term']?['Title'], r['term']?['title'], r['Title'], r['title'], r['name']]);
          if (t.trim().isNotEmpty) out.add(_clean(t));
        } else if (r is String) {
          if (r.trim().isNotEmpty) out.add(_clean(r));
        }
      }
      return out;
    }

    final rootTerms = data['terms'] ?? raw['terms'];
    if (rootTerms is List) {
      return rootTerms.map((t) {
        if (t is Map) return _pickFirstString([t['Title'], t['title'], t['name']]);
        return t?.toString() ?? '';
      }).where((s) => s.trim().isNotEmpty).map((s) => _clean(s)).toList();
    }

    return [];
  }

  // فرهنگ‌نامه (encyclopedia)
  String? get encyclopediaTitle {
    final t = _pickFirstString([data['encyclopedia']?['title'], data['Encyclopedia']?['Title'], data['encyclopedia_title']]);
    return _clean(t).isNotEmpty ? _clean(t) : null;
  }

  String? get encyclopediaDescription {
    final d = _pickFirstString([data['encyclopedia']?['description'], data['Encyclopedia']?['Description'], data['encyclopedia_description'], data['description']]);
    return _clean(d).isNotEmpty ? _clean(d) : null;
  }

  // preview: چند خط اول متن برای نمایش در کارت‌ها
  String _stripHtml(String s) => s.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  String get preview {
    final candidates = [
      encyclopediaDescription,
      abstractText,
      description,
      raw['excerpt']?.toString(),
      raw['summary']?.toString(),
      raw['snippet']?.toString(),
      data['excerpt']?.toString(),
      data['summary']?.toString(),
    ];
    String chosen = '';
    for (final c in candidates) {
      if (c == null) continue;
      final cleaned = _stripHtml(c);
      if (cleaned.isNotEmpty) { chosen = cleaned; break; }
    }
    if (chosen.isEmpty) return '';
    const maxLen = 160;
    if (chosen.length <= maxLen) return chosen;
    final cut = chosen.substring(0, maxLen);
    final lastSpace = cut.lastIndexOf(' ');
    return (lastSpace > 40) ? '${cut.substring(0, lastSpace)}…' : '${cut}…';
  }

  // متادیتا کتابخانه
  String? get volume => _clean(data['volume']?.toString()).isNotEmpty ? _clean(data['volume']?.toString()) : null;
  String? get from => _clean(data['from']?.toString()).isNotEmpty ? _clean(data['from']?.toString()) : null;
  String? get to => _clean(data['to']?.toString()).isNotEmpty ? _clean(data['to']?.toString()) : null;

  int? get pageCount {
    final candidates = [
      data['page_count'],
      data['PageCount'],
      data['pages_count'],
      raw['page_count'],
      raw['PageCount'],
      raw['pages_count'],
      docDetails?['page_count'],
      docDetails?['PageCount']
    ];
    for (final c in candidates) {
      final v = _toInt(c);
      if (v != null) return v;
    }
    return null;
  }

  // استخراج مستقیم details سرویس (برای LibraryDetailInfo)
  List<Map<String, String>> get serviceDetails {
    final cand = data['details'] ?? raw['details'] ?? raw['doc']?['details'] ?? data['doc']?['details'];
    if (cand is List) {
      final out = <Map<String, String>>[];
      for (final item in cand) {
        if (item is Map) {
          final type = (item['type'] ?? item['Type'] ?? '').toString();
          final title = (item['title'] ?? item['Title'] ?? item['value'] ?? '').toString();
          if (type.isNotEmpty || title.isNotEmpty) out.add({'type': type, 'title': title});
        }
      }
      return out;
    }
    return [];
  }

  @override
  String toString() => 'ThesaurusResult(title:${title}, id:${id ?? '(no id)'})';

  // عنوان نمایه
  String get indexTitle {
    final t = _pickFirstString([
      raw['title'],
      raw['Title'],
      data['title'],
      data['Title'],
      data['SimpleTitle'],
      data['word'],
      data['Word'],
    ]);
    if (_clean(t).isNotEmpty) return _clean(t);

    // fallback به slug اگر title خالی بود
    final slug = (raw['slug'] ?? raw['Slug'])?.toString() ?? '';
    if (slug.isNotEmpty) {
      final i = slug.indexOf('-');
      if (i >= 0 && i + 1 < slug.length) return _clean(slug.substring(i + 1));
      return _clean(slug);
    }
    return '';
  }

  /// اصطلاحات واقعی از سرویس (terms.data)
  List<Map<String, dynamic>> get serviceTerms {
    final termsData = raw['terms']?['data'];
    if (termsData is List) {
      return termsData.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}