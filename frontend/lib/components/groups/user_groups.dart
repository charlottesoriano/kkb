import 'package:KKB/components/global/balance_label.dart';
import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/global/label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/components/global/tile_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserGroupsList extends ConsumerStatefulWidget {
  const UserGroupsList({super.key, required this.groups, this.balances = const {}, this.onTap, this.onToggleFavorite, this.byUser = false});

  final List<Group> groups;
  // group id -> your net balance (positive = you're owed, negative = you owe)
  final Map<int, double> balances;
  final void Function(Group group)? onTap;
  final void Function(Group group, bool isFavorite)? onToggleFavorite;
  final bool byUser;
  @override
  ConsumerState<UserGroupsList> createState() => _UserGroupsListState();
}

class _UserGroupsListState extends ConsumerState<UserGroupsList> {
  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
  ];

  //the provider flips the flag optimistically and rolls back on failure
  Future<void> _toggleFavorite(Group group) async {
    final result = await ref.read(userGroupsProvider.notifier).toggleFavorite(group.id);
    if (!result.status) {
      if (mounted && context.mounted) Helper.showErrorSnackBar(context, result.message, action: DbAction.update);
      return;
    }
    widget.onToggleFavorite?.call(group, result.body as bool);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        KKBLabel(title: widget.byUser ? 'My groups' : 'Joined groups', subtitle: 'Created by ${widget.byUser ? 'you' : 'others'} · ${widget.groups.length}'),
        const SizedBox(height: 4),

        if (widget.groups.isEmpty)
          KKBEmptyState(title: 'No groups found', subtitle: '${widget.byUser ? 'Create a group' : 'Join a group'} to get started')
        else
          Column(spacing: 12, crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final group in widget.groups) _buildCard(group)]),
      ],
    );
  }

  Widget _buildCard(Group group) {
    final isFavorite = group.isFavorite;

    return KKBTileCard(
      title: group.name,
      // fall back to member count when the group has no description
      subtitle: group.description.isNotEmpty ? group.description : '${group.members.length} members',
      onTap: widget.onTap == null ? null : () => widget.onTap!(group),
      leading: _buildAvatar(group),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          BalanceLabel(balance: widget.balances[group.id] ?? 0),
          // favorite toggle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleFavorite(group),
            child: SvgIcon(icon: isFavorite ? KKBIcons.starFilled : KKBIcons.starOutlined, color: isFavorite ? KKBColors.lightPrimary : KKBColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Group group) {
    final (avatarColor, onAvatarColor) = _avatarColors[group.id % _avatarColors.length];

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(12)),
      child: Text(Helper.initials(group.name), style: KKBTextStyles.bodyMediumXBold.copyWith(color: onAvatarColor)),
    );
  }
}
