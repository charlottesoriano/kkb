import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/groups/selected_group.dart';

// selected group chip in the group header; tapping it goes back to the main navigation
class GroupHeaderCard extends ConsumerWidget {
  const GroupHeaderCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Group? selectedGroup = ref.watch(selectedGroupProvider);
    if (selectedGroup == null) return const SizedBox.shrink();

    final avatarColor = Helper.colorFromHex(selectedGroup.avatarColor);

    return Material(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ?? () => context.go(AppRoutes.groups),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: KKBColors.lightBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              const Icon(Icons.chevron_left_rounded, size: 24, color: KKBColors.lightTextPrimary),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  Helper.initials(selectedGroup.name),
                  style: KKBTextStyles.bodyXSmallBold.copyWith(color: avatarColor.computeLuminance() > 0.5 ? KKBColors.lightTextPrimary : KKBColors.lightOnPrimary),
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedGroup.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KKBTextStyles.bodyMediumXBold.copyWith(color: KKBColors.lightTextPrimary),
                    ),
                    Text(
                      '${selectedGroup.members.length} members',
                      style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
