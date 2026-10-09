import 'package:KKB/components/groups/header.dart';
import 'package:KKB/components/groups/join_create_group_panel.dart';
import 'package:KKB/components/groups/favorite_groups.dart';
import 'package:KKB/components/global/dashed_button.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/components/groups/user_groups.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GroupsIndex extends ConsumerStatefulWidget {
  const GroupsIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MGroupsIndexState();
}

class _MGroupsIndexState extends ConsumerState<GroupsIndex> {
  String _searchQuery = '';

  // select the group and open the group navigation
  void _openGroup(Group group) {
    ref.read(selectedGroupProvider.notifier).setSelectedGroup(group);
    context.go(AppRoutes.groupBalances);
  }

  @override
  Widget build(BuildContext context) {
    // filter by group name when the user is searching
    final String query = _searchQuery.trim().toLowerCase();
    List<Group> groups = ref.watch(userGroupsProvider)
        .where((group) => query.isEmpty || group.name.toLowerCase().contains(query))
        .toList();
    List<Group> favoriteGroups = groups.where((group) => group.isFavorite).toList();
    final String? userId = ref.watch(currentUserProvider)?.id;
    List<Group> createdByUserGroups = groups.where((group) => group.createdBy?.id == userId).toList();
    List<Group> joinedGroups = groups.where((group) => group.members.any((member) => member.id == userId) && group.createdBy?.id != userId).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(GroupsHeader.toolbarHeightForTwoLineTitle),
        child: GroupsHeader(onAddGroup: () => showJoinCreateGroupPanel(context)),
      ),
      body: RefreshIndicator(
        color: KKBColors.lightPrimary,
        onRefresh: () => ref.read(userGroupsProvider.notifier).fetchUserGroups(),
        child: SingleChildScrollView(
          // always scrollable so pull to refresh works even when the list is short
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                //search bar
                Column(
                  children: [
                    KKBTextField(
                      hintText: 'Search groups',
                      prefixIcon: Icon(Icons.search),
                      // built-in clear button, only shown while there's text
                      clearable: true,
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  
                    FavoriteGroupsList(groups: favoriteGroups, onTap: _openGroup),
                    UserGroupsList(groups: createdByUserGroups, byUser: true, onTap: _openGroup),
                    UserGroupsList(groups: joinedGroups, byUser: false, onTap: _openGroup),
                  
                    // const SizedBox(height: 16),
                    // KKBLabel(title: 'Joined groups', subtitle: 'Created by others • 3'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      // add / join group button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: KKBDashedButton(
            label: 'Join with a code or create a group',
            onTap: () => showJoinCreateGroupPanel(context),
          ),
        ),
      ),
    );
  }
}