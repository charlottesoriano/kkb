import 'package:KKB/components/groups/header.dart';
import 'package:KKB/components/groups/join_create_group_panel.dart';
import 'package:KKB/components/groups/favorite_groups.dart';
import 'package:KKB/components/global/dashed_button.dart';
import 'package:KKB/components/global/label.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/components/groups/user_groups.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsIndex extends ConsumerStatefulWidget {
  const GroupsIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MGroupsIndexState();
}

class _MGroupsIndexState extends ConsumerState<GroupsIndex> {

  @override
  Widget build(BuildContext context) {
    List<Group> groups = ref.watch(userGroupsProvider);
    List<Group> favoriteGroups = groups.where((group) => group.isFavorite).toList();
    final String? userId = ref.watch(currentUserProvider)?.id;
    List<Group> createdByUserGroups = groups.where((group) => group.createdBy?.id == userId).toList();
    List<Group> joinedGroups = groups.where((group) => group.members.any((member) => member.id == userId) && group.createdBy?.id != userId).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(GroupsHeader.toolbarHeightForTwoLineTitle),
        child: GroupsHeader(onAddGroup: () => showJoinCreateGroupPanel(context)),
      ),
      body: SingleChildScrollView(
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
                    onChanged: (value) {
                      
                    },
                  ),
                  
                  FavoriteGroupsList(groups: favoriteGroups),
                  UserGroupsList(groups: createdByUserGroups, byUser: true),
                  UserGroupsList(groups: joinedGroups, byUser: false),
                  
                  // const SizedBox(height: 16),
                  // KKBLabel(title: 'Joined groups', subtitle: 'Created by others • 3'),
                ],
              ),
            ],
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