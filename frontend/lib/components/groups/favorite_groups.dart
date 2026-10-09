import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/global/group_card.dart';
import 'package:KKB/components/global/label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_balances.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteGroupsList extends ConsumerStatefulWidget {
  const FavoriteGroupsList({
    super.key,
    required this.groups,
    this.onTap,
    this.onToggleFavorite,
  });

  final List<Group> groups;
  final void Function(Group group)? onTap;
  final void Function(Group group, bool isFavorite)? onToggleFavorite;

  @override
  ConsumerState<FavoriteGroupsList> createState() => _FavoriteGroupsListState();
}

class _FavoriteGroupsListState extends ConsumerState<FavoriteGroupsList> {
  static const double _cardWidth = 260;
  static const double _cardHeight = 200;

  @override
  void initState() {
    super.initState();
    _fetchCardData(widget.groups);
  }

  @override
  void didUpdateWidget(covariant FavoriteGroupsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // only fetch groups that were just added to favorites
    final oldIds = oldWidget.groups.map((group) => group.id).toSet();
    _fetchCardData(widget.groups.where((group) => !oldIds.contains(group.id)));
  }

  // each card's balance and pending payments come from that group's own providers
  void _fetchCardData(Iterable<Group> groups) {
    for (final group in groups) {
      ref.read(groupBalancesProvider(group.id).notifier).fetchGroupBalances();
      ref.read(groupSettlementsProvider(group.id).notifier).fetchGroupSettlements();
    }
  }

  //the provider flips the flag optimistically and rolls back on failure
  Future<void> _toggleFavorite(Group group) async {
    final result = await ref.read(userGroupsProvider.notifier).toggleFavorite(group.id);
    if (!result.status) {
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Could not update favorites'), backgroundColor: KKBColors.lightTextError));
      return;
    }
    widget.onToggleFavorite?.call(group, result.body as bool);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        KKBLabel(
          title: 'Favorites',
          subtitle: widget.groups.length > 1 ? 'Swipe for more' : '',
          leading: SvgIcon(icon: KKBIcons.starFilled, color: KKBColors.lightPrimary),
        ),
        const SizedBox(height: 4),
        if (widget.groups.isEmpty)
          const KKBEmptyState(title: 'No favorite groups found', subtitle: 'Add some groups to your favorites to see them here')
        else
          SizedBox(
            height: _cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // lets the next card peek past the parent's padding
              clipBehavior: Clip.none,
              itemCount: widget.groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final group = widget.groups[index];
                final balance = ref.watch(groupBalancesProvider(group.id)).where((b) => b.user.id == userId).firstOrNull?.amount ?? 0;
                // payments other members recorded that are waiting on you to confirm
                final pendingConfirmations = ref.watch(groupSettlementsProvider(group.id)).where((s) => s.status == 'pending' && s.toUser.id == userId).length;

                return KKBGroupCard(
                  group: group,
                  width: _cardWidth,
                  balance: balance,
                  isFavorite: group.isFavorite,
                  pendingConfirmations: pendingConfirmations,
                  onTap: widget.onTap == null ? null : () => widget.onTap!(group),
                  onToggleFavorite: () => _toggleFavorite(group),
                );
              },
            ),
        ),
      ],
    );
  }
}
