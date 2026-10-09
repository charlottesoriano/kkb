import 'package:KKB/models/response_status.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserProfileSettings {
  final Ref ref;

  UserProfileSettings(this.ref);

  //soft-deletes the signed-in user, the backend reads the user id from the auth token
  Future<ResponseStatus> deleteUserProfile() => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation RemoveUser {
            removeUser { id }
          }
        '''),
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    return ResponseStatus(message: 'Account deleted successfully', status: true, body: result.data?['removeUser']);
  });

  //update user profile -> only the display name, first name, and last name are updatable
  Future<ResponseStatus> updateUserProfile({
    required String id,
    required String firstName,
    required String lastName,
    required String displayName,
  }) => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UpdateUser($input: UpdateUserInput!) {
            updateUser(updateUserInput: $input) { id first_name last_name display_name }
          }
        '''),
        variables: {
          'input': {
            'id': id,
            'first_name': firstName,
            'last_name': lastName,
            'display_name': displayName,
          },
        },
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    return ResponseStatus(message: 'Profile updated successfully', status: true, body: result.data?['updateUser']);
  });
}

final userProfileSettingsProvider = Provider<UserProfileSettings>((ref) {
  final settings = UserProfileSettings(ref);
  return settings;
});
