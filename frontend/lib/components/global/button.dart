import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// height, corner radius, text style, horizontal padding and icon size presets
enum KKBButtonSize {
  large(56, 16, KKBTextStyles.buttonLarge, 20, 20),
  medium(48, 14, KKBTextStyles.buttonMedium, 20, 18),
  small(36, 12, KKBTextStyles.buttonSmall, 14, 16);

  const KKBButtonSize(this.height, this.radius, this.textStyle, this.horizontalPadding, this.iconSize);

  final double height;
  final double radius;
  final TextStyle textStyle;
  final double horizontalPadding;
  final double iconSize;
}

// primary filled button, or outlined when isOutlined is true
class KKBButton extends StatelessWidget {
  const KKBButton({super.key, required this.label, required this.onPressed, this.isOutlined = false, this.size = KKBButtonSize.medium, this.icon, this.leading, this.height, this.isLoading = false});

  final String label;
  // null disables the button
  final VoidCallback? onPressed;
  final bool isOutlined;
  final KKBButtonSize size;
  // optional leading icon
  final IconData? icon;
  // custom leading widget, e.g. the Google "G" badge; used instead of icon
  final Widget? leading;
  // override the size's height, e.g. to line up with a text field
  final double? height;
  // shows a spinner instead of the label and disables the button
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final minimumSize = Size(0, height ?? size.height);
    final padding = EdgeInsets.symmetric(horizontal: size.horizontalPadding);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.radius));
    final onPressed = isLoading ? null : this.onPressed;
    final text = isLoading
        ? SizedBox.square(
            dimension: size.iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: isOutlined ? KKBColors.lightTextPrimary : KKBColors.lightOnPrimary),
          )
        : Text(label, style: size.textStyle);
    final iconWidget = isLoading ? null : leading ?? (icon == null ? null : Icon(icon, size: size.iconSize));

    if (isOutlined) {
      final style = OutlinedButton.styleFrom(
        foregroundColor: KKBColors.lightTextPrimary,
        backgroundColor: KKBColors.lightSurface,
        side: const BorderSide(color: KKBColors.lightBorder),
        minimumSize: minimumSize,
        padding: padding,
        shape: shape,
      );
      return iconWidget == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: text)
          : OutlinedButton.icon(onPressed: onPressed, style: style, icon: iconWidget, label: text);
    }

    final style = FilledButton.styleFrom(
      backgroundColor: KKBColors.lightPrimary,
      foregroundColor: KKBColors.lightOnPrimary,
      disabledBackgroundColor: KKBColors.lightPrimary.withValues(alpha: 0.4),
      disabledForegroundColor: KKBColors.lightOnPrimary,
      minimumSize: minimumSize,
      padding: padding,
      shape: shape,
    );
    return iconWidget == null
        ? FilledButton(onPressed: onPressed, style: style, child: text)
        : FilledButton.icon(onPressed: onPressed, style: style, icon: iconWidget, label: text);
  }
}
