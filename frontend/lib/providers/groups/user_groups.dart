import 'dart:convert';

import 'package:KKB/models/group.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/global/graphql_client.dart';
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
    return Group(id: data['id'], name: data['name'] ?? '', description: data['description'] ?? '', members: membersList, isFavorite: data['is_favorite'] ?? false, createdBy: createdBy, createdAt: data['created_at'] ?? '');
  }

  Future<ResponseStatus> createGroup(String name, String description) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation CreateGroup($name: String!, $description: String) {
            createGroup(input: {name: $name, description: $description}) { id }
          }
        '''),
        variables: {
          "name": name,
          "description": description,
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
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query UserGroups {
            userGroups { 
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
            }
          }
        '''),
        //always hit the server, the default (cacheFirst) returns the stale list after a create/join
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
      // throw Exception(Helper.error(result));
    }

    if (result.data == null) {
      return ResponseStatus(message: 'No groups found', status: false, body: {});
    }

    final List<dynamic> userGroups = result.data?['userGroups'] ?? [];
    List<Group> groups = userGroups.map((group) => _parseGroup(group)).toList();

    state = groups;

    return ResponseStatus(message: 'User groups fetched successfully', status: true, body: groups);
  });

  Future<ResponseStatus> favoriteGroups() => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query FavoriteGroups {
            favoriteGroups { 
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
            }
          }
        '''),
        //always hit the server, the default (cacheFirst) returns stale favorites after a toggle
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    if (result.data == null) {
      return ResponseStatus(message: 'No favorite groups found', status: false, body: {});
    }

    final List<dynamic> favoriteGroups = result.data?['favoriteGroups'] ?? [];
    final Map<int, Group> favoritesById = {
      for (var group in favoriteGroups) group['id'] as int: _parseGroup(group),
    };

    //groups missing from the response were unfavorited, so clear their flag
    List<Group> currentState = state
        .map((g) => favoritesById[g.id] ?? g.copyWith(isFavorite: false))
        .toList();
    //add favorites not yet in state
    final existingIds = state.map((g) => g.id).toSet();
    currentState.addAll(favoritesById.values.where((g) => !existingIds.contains(g.id)));
    state = currentState;

    return ResponseStatus(message: 'Favorite groups fetched successfully', status: true, body: state);

  });

  //sets a group's favorite flag in state
  void _setFavorite(int groupId, bool isFavorite) {
    state = [for (final g in state) g.id == groupId ? g.copyWith(isFavorite: isFavorite) : g];
  }

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
}
