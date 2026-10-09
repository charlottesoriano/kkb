import 'package:KKB/models/group.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/user_groups.g.dart';

@Riverpod(keepAlive: true)
class UserGroups extends _$UserGroups {
  @override
  List<Group> build() {
    return [];
  }

  // parse a group from the graphql response
  Group _parseGroup(Map<String, dynamic> data) {
    List<User> membersList = [];
    for (var member in data['members'] ?? []) {
      membersList.add(User(id: member['id'], email: member['email'], displayName: member['display_name'], firstName: member['first_name'], lastName: member['last_name'], imageUrl: member['image_url'], createdAt: member['created_at']));
    }
    // creator may no longer be a member, so don't throw if not found
    User? createdBy = membersList.where((member) => member.id == data['created_by']).firstOrNull;
    return Group(id: data['id'], code: data['code'] ?? '', name: data['name'] ?? '', description: data['description'] ?? '', members: membersList, isFavorite: data['is_favorite'] ?? false, createdBy: createdBy, createdAt: data['created_at'] ?? '', avatarColor: data['avatar_color'] ?? '#984063');
  }

  
  //sets a group's favorite flag in state
  void _setFavorite(int groupId, bool isFavorite) {
    state = [for (final g in state) g.id == groupId ? g.copyWith(isFavorite: isFavorite) : g];
  }

  Future<ResponseStatus> createGroup(String name, String description, String avatarColor) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateGroup($name: String!, $description: String, $avatarColor: String) {
            createGroup(input: {name: $name, description: $description, avatarColor: $avatarColor}) { id }
          }
        '''),
        variables: {
          "name": name,
          "description": description,
          "avatarColor": avatarColor,
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
      // throw Exception(Helper.error(result));
    }

    //refresh the groups so the new group shows up
    await fetchUserGroups();
    return ResponseStatus(message: 'Group created successfully', status: true, body: result.data);
  });

  Future<ResponseStatus> addMemberToGroup(String groupCode) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation AddMemberToGroup($groupCode: String!) {
            addMemberToGroup(groupCode: $groupCode) { 
              id
              name
              description
              members {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              is_favorite
              created_at
              created_by
              avatar_color
            }
          }
        '''),
        variables: {
          "groupCode": groupCode,
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    final data = result.data?['addMemberToGroup'];
    if (data == null) {
      return ResponseStatus(message: 'No group found', status: false, body: {});
    }

    //parse the result.data to a Group object
    Group group = _parseGroup(data);
    state = [group, ...state];

    return ResponseStatus(message: 'Group joined successfully', status: true, body: data);
    
  });

  Future<void> fetchUserGroups() => Helper.guard(() async {
    // print('----> fetchUserGroups');
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query UserGroups {
            userGroups { 
              id
              code
              name
              description
              members {
                id
                email
                display_name
                first_name
                last_name
                image_url
                created_at
              }
              is_favorite
              created_at
              created_by
              avatar_color
            }
          }
        '''),
        //always hit the server, the default (cacheFirst) returns the stale list after a create/join
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    // print('----> result: ${result.data}');

    if (result.hasException) {
      // print('----> result.hasException: ${Helper.error(result)}');
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
      // throw Exception(Helper.error(result));
    }

    if (result.data == null) {
      // print('----> result.data is null');
      return ResponseStatus(message: 'No groups found', status: false, body: {});
    }

    // print('----> result.data is not null');

    final List<dynamic> userGroups = result.data?['userGroups'] ?? [];
    // print('----> userGroups: $userGroups');
    List<Group> groups = userGroups.map((group) => _parseGroup(group)).toList();
    // print('----> groups: $groups');

    //order groups by created_at descending
    groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // print('----> groups sorted: $groups');
    //if there is no selected group, set the first group as selected
    if(groups.isNotEmpty) setSelectedGroup(groups.first);
    // print('----> setSelectedGroup: ${groups.first}');

    state = groups;

    return ResponseStatus(message: 'User groups fetched successfully', status: true, body: groups);
  });

  Future<ResponseStatus> toggleFavorite(int groupId) async {
    final previous = state.where((g) => g.id == groupId).firstOrNull?.isFavorite ?? false;
    //optimistic update so the star flips right away
    _setFavorite(groupId, !previous);

    final response = await Helper.guard(() async {
      final client = ref.read(graphqlClientProvider);
      final result = await client.mutate(
        MutationOptions(
          document: gql(r'''
            mutation FavoriteGroup($groupId: Int!) {
              favoriteGroup(groupId: $groupId)
            }
          '''),
          variables: {
            "groupId": groupId,
          },
        )
      );

      if (result.hasException) {
        return ResponseStatus(message: Helper.error(result), status: false, body: {});
      }

      final bool isFavorite = result.data?['favoriteGroup'] ?? !previous;
      return ResponseStatus(message: isFavorite ? 'Added to favorites' : 'Removed from favorites', status: true, body: isFavorite);
    });

    //use the server's status, or roll back if the request failed
    _setFavorite(groupId, response.status ? response.body as bool : previous);
    return response;
  }

  void setSelectedGroup(Group group) {
    Group? selectedGroup = ref.read(selectedGroupProvider);
    if (selectedGroup == null) {
      ref.read(selectedGroupProvider.notifier).setSelectedGroup(group);
    }
  }
}
