import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'detail/thesaurus_detail.dart';

class ThesaurusResultsList extends StatelessWidget {
  final List<ThesaurusResult> results;
  final String query;
  final double Function(BuildContext) pad;

  const ThesaurusResultsList({
    super.key,
    required this.results,
    required this.query,
    required this.pad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
      itemBuilder: (ctx, i) {
        final r = results[i];
        final w = MediaQuery.of(ctx).size.width;
        final isMobile = w < 750;

        return InkWell(
          onTap: () {
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => ThesaurusDetailPage(
                  result: r,
                  searchQuery: query,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 7 : 14,
              horizontal: pad(ctx),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // عنوان
                Text(
                  r.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: const Color.fromARGB(255, 64, 147, 67),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: isMobile ? 4 : 6),

                // موبایل
                if (isMobile) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${r.relationsCount ?? 0} رابطه',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.share, size: 19, color: cs.primary),
                    ],
                  ),

                  SizedBox(height: 10),

                  if (r.status != null || r.pref != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${r.status ?? ''} | ${r.pref ?? ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],

                // دسکتاپ
                if (!isMobile)
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${r.relationsCount ?? 0} رابطه',
                            style: TextStyle(color: cs.primary),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.share, size: 22, color: cs.primary),
                        ],
                      ),

                      Expanded(
                        child: Center(
                          child: (r.status != null || r.pref != null)
                              ? Text(
                                  '${r.status ?? ''} | ${r.pref ?? ''}',
                                  style: const TextStyle(color: Colors.grey),
                                )
                              : const SizedBox(),
                        ),
                      ),

                      const SizedBox(width: 1),
                    ],
                  ),

                SizedBox(height: isMobile ? 4 : 6),

                if (r.domain != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      r.domain!,
                      style: TextStyle(
                        color: cs.primary.withOpacity(0.7),
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },)
    );
  }
}