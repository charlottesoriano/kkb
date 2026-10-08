import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:flutter/material.dart';

// notification bell on the right of the group header
class GroupHeaderBell extends StatelessWidget {
  const GroupHeaderBell({
    super.key,
    this.hasNotifications = false,
    this.onTap,
  });

  // shows the red dot on the bell
  final bool hasNotifications;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KKBColors.lightBorder),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SvgIcon(icon: KKBIcons.bell, size: 20, color: KKBColors.lightTextPrimary),
              if (hasNotifications)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: KKBColors.lightNotificationDot,
                      shape: BoxShape.circle,
                      border: Border.all(color: KKBColors.lightSurface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
