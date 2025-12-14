import 'package:flutter/material.dart';
import '../../../model/result.dart';
import 'package:go_router/go_router.dart';

class ThesaurusCard extends StatelessWidget {
  final ThesaurusResult result;

  const ThesaurusCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    final title = result.title;
    final domain = result.domain ?? '';
    final indexesCount = result.indexesCount ?? 0;
    final relationsCount = result.relationsCount ?? 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: 250,
        height: 180,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              context.push(
                '/thesaurus/detail/${result.id}',
                extra: result,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      title.isNotEmpty ? title : '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: c.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // دامنه
                  if (domain.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: c.primary.withOpacity(0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          domain,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: c.primary.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 8),

                  // بخش پایین
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // نمایه
                      Row(
                        children: [
                          Text(
                            '$indexesCount نمایه',
                            style: TextStyle(
                              color: c.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.article, size: 22, color: c.primary),
                        ],
                      ),
                      const SizedBox(width: 40),
                      // رابطه
                      Row(
                        children: [
                          Text(
                            '$relationsCount رابطه',
                            style: TextStyle(
                              color: c.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.share_outlined, size: 22, color: c.primary),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}