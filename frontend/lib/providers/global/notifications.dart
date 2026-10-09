import 'package:KKB/models/notification.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/notifications.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  @override
  List<Notification> build() {
    return [];
  }

  // parse a user from the graphql response, the backend only joins id and names so the rest fall back to defaults
  

  // parse a notification from the graphql response
  Notification _parseNotification(Map<String, dynamic> data) {
    return Notification(id: data['id'], fromUser: Helper.parseUser(data['from_user']), toUser: Helper.parseUser(data['to_user']), title: data['title'] ?? '', description: data['description'] ?? '', createdAt: data['created_at'] ?? '');
  }

  Future<ResponseStatus> fetchUserNotifications() => Helper.guard(() async {
    final client = ref.read(graphqlClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(r'''
          query GetUserNotifications {
            getUserNotifications {
              id
              from_user {
                id
                display_name
                first_name
                last_name
              }
              to_user {
                id
                display_name
                first_name
                last_name
              }
              title
              description
              created_at
            }
          }
        '''),
        //always hit the server so new notifications show up
        fetchPolicy: FetchPolicy.networkOnly,
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    if (result.data == null) {
      return ResponseStatus(message: 'No notifications found', status: false, body: {});
    }

    final List<dynamic> userNotifications = result.data?['getUserNotifications'] ?? [];
    List<Notification> notifications = userNotifications.map((notification) => _parseNotification(notification)).toList();

    //order notifications by created_at descending, newest on top
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = notifications;

    return ResponseStatus(message: 'User notifications fetched successfully', status: true, body: notifications);
  });
}
