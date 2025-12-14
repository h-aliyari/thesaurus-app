import 'package:flutter/material.dart';
import 'feature_block.dart';
import '../base_screen.dart';

Widget buildLexiconIntro(String Function(String fa, String en) t) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const FullWidthWidget(
        child: ThesaurusFeatureBlock(),
      ),
    ],
  );
}
