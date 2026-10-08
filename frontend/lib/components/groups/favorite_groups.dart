import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/global/group_card.dart';
import 'package:KKB/components/global/label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteGroupsList extends ConsumerStatefulWidget {
  const FavoriteGroupsList({
    super.key,
    required this.groups,
    this.balances = const {},
    this.pendingConfirmations = const {},
    this.onTap,
    this.onToggleFavorite,
  });

  final List<Group> groups;
  // group id -> your net balance (positive = you're owed, negative = you owe)
  final Map<int, double> balances;
  // group id -> number of payments waiting on you to confirm
  final Map<int, int> pendingConfirmations;
  final void Function(Group group)? onTap;
  final void Function(Group group, bool isFavorite)? onToggleFavorite;

  @override
  ConsumerState<FavoriteGroupsList> createState() => _FavoriteGroupsListState();
}

class _FavoriteGroupsListState extends ConsumerState<FavoriteGroupsList> {
  static const double _cardWidth = 260;
  static const double _cardHeight = 200;

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
          
                return KKBGroupCard(
                  group: group,
                  width: _cardWidth,
                  balance: widget.balances[group.id] ?? 0,
                  isFavorite: group.isFavorite,
                  pendingConfirmations: widget.pendingConfirmations[group.id] ?? 0,
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
