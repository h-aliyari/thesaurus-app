import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../model/result.dart';
import '../../../screen/translate.dart';

class LibraryCard extends StatelessWidget {
  final ThesaurusResult result;
  final double cardHeight;

  const LibraryCard({
    super.key,
    required this.result,
    this.cardHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ct = Theme.of(context).cardTheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: cardHeight,
      child: Card(
        color: ct.color,
        elevation: ct.elevation ?? 2,
        margin: ct.margin,
        shadowColor: ct.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
            color: Color.fromARGB(255, 98, 97, 97),
            width: 0.3,
          ),
        ),
        child: InkWell(
          onTap: () {
            context.push(
              '/resources/detail/${result.id}',
              extra: result,
            );
          },
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(
                  height: 48,
                  child: Text(
                    result.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: textTheme.titleMedium?.copyWith(
                      color: cs.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: cs.secondary.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        t(context, ':انتشارات', 'Publications:', ':المنشورات'),
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        result.publisher ?? '',
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: cs.secondary.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        t(context, ':نویسنده', 'Author:', ':المؤلف'),
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        result.author ?? '',
                        softWrap: true,
                        textAlign: TextAlign.right,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}