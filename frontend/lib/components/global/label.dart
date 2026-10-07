import 'package:flutter/material.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

class KKBLabel extends StatefulWidget {
  const KKBLabel({super.key, required this.title, this.subtitle = '', this.leading, this.trailing});

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<KKBLabel> createState() => _KKBLabelState();
}

class _KKBLabelState extends State<KKBLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: widget.leading != null ? 10 : 0,
            children: [
              widget.leading ?? const SizedBox.shrink(),
              Text(widget.title, style: KKBTextStyles.headerXXSmall),
            ],
          ),
          Row(
            spacing: widget.trailing != null ? 10 : 0,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(widget.subtitle, style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary)),
              ),
              widget.trailing ?? const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}