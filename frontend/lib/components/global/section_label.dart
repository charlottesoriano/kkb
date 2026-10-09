import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// small heading above a section or input, e.g. "Who paid?", "Amount"
class KKBSectionLabel extends StatelessWidget {
  const KKBSectionLabel(this.text, {super.key, this.style = KKBTextStyles.bodySmallSemiBold});

  final String text;
  // base style; the text color is applied on top
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style.copyWith(color: KKBColors.lightTextPrimary));
  }
}
