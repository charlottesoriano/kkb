import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:KKB/providers/global/graphql_client.dart';

// runs on a separate isolate when a push arrives while the app is closed;
// the system tray already shows notification pushes, so there's nothing to do yet
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {

}

StreamSubscription<String>? _tokenRefresh;

// gets this device's FCM token and saves it for the signed-in user
Future<void> registerPushToken(WidgetRef ref) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) await _saveToken(ref, token);
    // FCM can rotate the token; only subscribe once
    _tokenRefresh ??= messaging.onTokenRefresh.listen((token) => _saveToken(ref, token));
  } catch (e) {
    debugPrint('FCM token not registered: $e');
  }
}

// removes this device's token for the signed-in user; call before signing out, the mutation needs the Clerk token
Future<void> unregisterPushToken(GraphQLClient client) async {
  try {
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;

    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token == null) return;
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation UnregisterDeviceToken($token: String!) {
            unregisterDeviceToken(token: $token)
          }
        '''),
        variables: {"token": token},
      ),
    );
    if (result.hasException) debugPrint('FCM token not removed: ${result.exception}');
    // a fresh token is issued and saved at the next sign in
    await messaging.deleteToken();
  } catch (e) {
    debugPrint('FCM token not removed: $e');
  }
}

Future<void> _saveToken(WidgetRef ref, String token) async {
  final result = await ref.read(graphqlClientProvider).mutate(
    MutationOptions(
      document: gql(r'''
        mutation RegisterDeviceToken($token: String!) {
          registerDeviceToken(token: $token)
        }
      '''),
      variables: {"token": token},
    ),
  );
  if (result.hasException) debugPrint('FCM token not saved: ${result.exception}');
}