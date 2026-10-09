import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

class KKBTitle extends StatefulWidget {
  const KKBTitle({super.key, required this.title});

  final String title;

  @override
  State<KKBTitle> createState() => _KKBTitleState();
}

class _KKBTitleState extends State<KKBTitle> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.title, style: KKBTextStyles.headerLarge);
  }
}