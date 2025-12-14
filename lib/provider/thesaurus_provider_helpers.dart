int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v.trim());
  return null;
}

int? parsePageCountFromDetails(Map<String, dynamic>? details) {
  if (details == null) return null;
  dynamic raw = details['page_count'] ?? details['PageCount'];
  if (details['doc'] is Map) raw = details['doc']['page_count'] ?? raw;
  if (details['doc_details'] is Map) raw = details['doc_details']['page_count'] ?? raw;
  return _toInt(raw);
}

int? parsePageCountFromDocPart(Map<String, dynamic>? docPart) {
  if (docPart == null) return null;
  dynamic raw = docPart['page_count'] ?? docPart['PageCount'] ?? docPart['pages_count'];
  if (docPart['doc_details'] is Map) raw = docPart['doc_details']['page_count'] ?? raw;
  return _toInt(raw);
}

List<String> parseTermsFromDetails(Map<String, dynamic>? details) {
  if (details == null) return [];
  final rootTerms = details['terms'];
  final docTerms = (details['doc'] is Map) ? details['doc']['terms'] : null;
  final list = rootTerms is List ? rootTerms : (docTerms is List ? docTerms : []);
  return _extractTitlesFromTermsList(list);
}

List<String> parseTermsFromDocPart(Map<String, dynamic>? docPart) {
  if (docPart == null) return [];
  final termsRaw = docPart['terms'];
  return _extractTitlesFromTermsList(termsRaw is List ? termsRaw : []);
}

List<String> _extractTitlesFromTermsList(List<dynamic> list) {
  final out = <String>[];
  for (final t in list) {
    if (t is Map) {
      final title = t['title'] ?? t['Title'] ?? t['name'] ?? t['slug'];
      if (title != null) out.add(title.toString());
    } else if (t is String) {
      out.add(t);
    }
  }
  return out;
}
