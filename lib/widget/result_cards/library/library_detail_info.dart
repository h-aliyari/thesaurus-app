import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../model/result.dart';

class LibraryDetailInfo extends StatelessWidget {
  final ThesaurusResult result;
  const LibraryDetailInfo({super.key, required this.result});

  List<Map<String, String>> _serviceDetails() {
    final cand = result.serviceDetails.isNotEmpty
        ? result.serviceDetails
        : _extractFromRaw(result.raw) ?? [];
    return cand;
  }

  List<Map<String, String>>? _extractFromRaw(Map<String, dynamic> raw) {
    try {
      final rootDetails = raw['details'];
      if (rootDetails is List && rootDetails.isNotEmpty) {
        return _normalizeDetailsList(rootDetails);
      }

      final doc = raw['doc'];
      if (doc is Map) {
        final docDetails = doc['details'];
        if (docDetails is List && docDetails.isNotEmpty) {
          return _normalizeDetailsList(docDetails);
        }

        final termRelations = doc['term_relations'] ?? doc['termRelations'] ?? doc['relations'];
        if (termRelations is List && termRelations.isNotEmpty) {
          final out = <Map<String, String>>[];
          for (final r in termRelations) {
            if (r is Map) {
              final typeFromType = (r['type'] is Map) ? (r['type']['Title'] ?? r['type']['title']) : null;
              final termTitle = (r['term'] is Map) ? (r['term']['Title'] ?? r['term']['title']) : null;
              final valueFromValue = r['Value'] ?? r['value'];

              final type = (typeFromType ?? '').toString().trim();
              final title = (termTitle ?? valueFromValue ?? '').toString().trim();

              if (type.isNotEmpty || title.isNotEmpty) out.add({'type': type, 'title': title});
            }
          }
          if (out.isNotEmpty) return out;
        }
      }

      final relations = raw['relations'];
      if (relations is List && relations.isNotEmpty) {
        return _normalizeDetailsList(relations);
      }
    } catch (_) {}
    return null;
  }

  List<Map<String, String>> _normalizeDetailsList(List<dynamic> list) {
    final out = <Map<String, String>>[];
    for (final item in list) {
      if (item is Map) {
        final type = (item['type'] ?? item['Type'] ?? (item['type'] is Map ? item['type']['Title'] : null) ?? '').toString();
        final title = (item['title'] ?? item['Title'] ?? item['value'] ?? item['Value'] ?? '').toString();
        if (type.trim().isNotEmpty || title.trim().isNotEmpty) {
          out.add({'type': type.trim(), 'title': title.trim()});
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final details = _serviceDetails();

    if (kDebugMode) {
      debugPrint('DEBUG LibraryDetailInfo: details count=${details.length}');
      if (details.isNotEmpty) debugPrint('DEBUG LibraryDetailInfo sample=${details.take(5).toList()}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // عنوان کتاب
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            result.title.isNotEmpty ? result.title : 'بدون عنوان',
            style: textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              fontSize: 19
            ),
            textAlign: TextAlign.right,
          ),
        ),

        const SizedBox(height: 25),

        if (details.isNotEmpty) ...details.map((d) {
          final titleText = (d['title'] ?? '-').toString();
          final typeText = (d['type'] ?? '').toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // عنوان
                Expanded(
                  child: Text(
                    titleText.isNotEmpty ? titleText : '-',
                    textAlign: TextAlign.right,
                    style: textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(width: 12),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      typeText.isNotEmpty ? '$typeText:' : '',
                      style: textTheme.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}