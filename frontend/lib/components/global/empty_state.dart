import 'package:flutter/material.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

class KKBEmptyState extends StatelessWidget {
  const KKBEmptyState({super.key, required this.title, this.subtitle = ''});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Text(title, style: KKBTextStyles.titleSmall, textAlign: TextAlign.center),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
