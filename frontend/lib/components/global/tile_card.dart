import 'package:flutter/material.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

class KKBTileCard extends StatelessWidget {
  const KKBTileCard({
    super.key,
    required this.title,
    this.subtitle = '',
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KKBColors.lightBorder),
          ),
          child: Row(
            spacing: 12,
            children: [
              ?leading,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KKBTextStyles.bodyLargeBold.copyWith(color: KKBColors.lightTextPrimary),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
