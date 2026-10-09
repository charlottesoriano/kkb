import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// color presets for the chip
enum StatusChipVariant {
  neutral(KKBColors.lightChip, KKBColors.lightTextPrimary),
  success(KKBColors.lightOwedBackground, KKBColors.lightOwed),
  danger(KKBColors.lightOweBackground, KKBColors.lightOwe),
  muted(KKBColors.lightSurfaceVariant, KKBColors.lightTextSecondary);

  const StatusChipVariant(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

// padding + text style presets
enum StatusChipSize {
  small(EdgeInsets.symmetric(horizontal: 8, vertical: 3), KKBTextStyles.labelSmallBold),
  medium(EdgeInsets.symmetric(horizontal: 10, vertical: 4), KKBTextStyles.bodyXSmallBold);

  const StatusChipSize(this.padding, this.textStyle);

  final EdgeInsets padding;
  final TextStyle textStyle;
}

// small rounded pill for statuses and short labels (Paid, Pending, "2 to confirm", ...)
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.variant = StatusChipVariant.neutral, this.size = StatusChipSize.medium, this.icon, this.background, this.foreground, this.padding});

  // chip for a settlement status: paid / pending / rejected, anything else shows as unpaid
  factory StatusChip.settlement(String status, {Key? key, StatusChipSize size = StatusChipSize.medium}) {
    final (label, variant) = switch (status) {
      'paid' => ('Paid', StatusChipVariant.success),
      'pending' => ('Pending', StatusChipVariant.neutral),
      'rejected' => ('Rejected', StatusChipVariant.danger),
      _ => ('Unpaid', StatusChipVariant.muted),
    };
    return StatusChip(key: key, label: label, variant: variant, size: size);
  }

  final String label;
  final StatusChipVariant variant;
  final StatusChipSize size;
  // optional leading icon
  final IconData? icon;
  // override the variant colors, e.g. on dark/hero backgrounds
  final Color? background;
  final Color? foreground;
  // override the size's padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? variant.foreground;

    return Container(
      padding: padding ?? size.padding,
      decoration: BoxDecoration(color: background ?? variant.background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (icon != null) Icon(icon, size: 14, color: fg),
          Text(label, style: size.textStyle.copyWith(color: fg)),
        ],
      ),
    );
  }
}
