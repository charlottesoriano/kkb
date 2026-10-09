# Push notifications (Firebase Cloud Messaging)

How KKB sends push notifications, and what's left to do. Update this as things change or break.

## How it works

1. When a user signs in, the app asks for notification permission, gets the device's FCM token and saves it with the `registerDeviceToken` mutation (stored in the `device_tokens` table).
2. Every notification goes through `NotificationsService.create()` in the backend. It saves the row in `notifications`, then pushes it to every token the receiver (`to_user`) has.
3. Tokens that FCM reports as dead (app uninstalled, expired) are deleted after a send.

So far this covers "Payment recorded" (settlement moved to `pending`) and the **Remind** button on suggested payments.

## Status

- [x] `firebase_core`, `firebase_messaging` (frontend) and `firebase-admin` (backend) installed
- [x] `device_tokens` and `notifications` tables in `backend/supabase/schema.sql`
- [x] Notifications saved for payment recorded and reminders
- [ ] Firebase CLI installed and logged in
- [ ] `flutterfire configure` run (creates `firebase_options.dart` + `google-services.json`)
- [ ] Service account keys in `backend/.env`
- [ ] Backend: Firebase provider, `registerDeviceToken`, push on `create()`
- [ ] Frontend: `core/push.dart`, Firebase init in `main.dart`, register on sign-in
- [ ] Tested on a real Android device / emulator with Google Play
- [ ] iOS (needs Apple Developer account + APNs key)

## Part 1: Firebase setup

### 1. Install the Firebase CLI

`flutterfire configure` uses the Firebase CLI to log in and list projects, so this is needed first.

```bash
npm install -g firebase-tools
firebase login
```

Node is managed by nvm here, so the global install belongs to the active Node version. If you switch Node versions later, `firebase` may disappear and need reinstalling.

### 2. Put the FlutterFire CLI on PATH

`flutterfire` is installed (`dart pub global activate flutterfire_cli`), but its folder isn't on PATH, so the command isn't found.

Add this folder to your user PATH (Windows: *Edit the system environment variables* → *Environment Variables* → *Path* under your user → *New*), then restart the terminal and VS Code:

```
%LOCALAPPDATA%\Pub\Cache\bin
```

For the current Git Bash session only:

```bash
export PATH="$PATH:$LOCALAPPDATA/Pub/Cache/bin"
```

In Git Bash, call it as `flutterfire.bat` (Git Bash doesn't add `.bat` on its own). PowerShell and cmd accept plain `flutterfire`. Or skip PATH entirely:

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

### 3. Create the project and connect the app

1. Create a project at https://console.firebase.google.com.
2. The Android package name is still `com.example.frontend` (`frontend/android/app/build.gradle.kts`). If it's going to be renamed, rename it **before** this step, since Firebase is tied to it.
3. In `frontend/`:

   ```bash
   flutterfire configure
   ```

   Pick the project and the platforms (Android at least). This creates `lib/firebase_options.dart` and `android/app/google-services.json`, and adds the Google Services Gradle plugin.

### 4. Backend credentials

Firebase console → Project settings → Service accounts → **Generate new private key**. Copy three values from the downloaded JSON into `backend/.env` (gitignored), then delete the JSON file:

```
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

Keep the quotes and the literal `\n`s on the private key; the provider turns them back into newlines.

### 5. iOS (later)

Needs an Apple Developer account, an APNs key uploaded in Firebase (Project settings → Cloud Messaging), and the Push Notifications + Background Modes capabilities in Xcode. Get Android working first.

## Part 2: Code

### Backend

**`backend/src/notifications/firebase.provider.ts`** (new), same pattern as `supabaseProvider`:

```ts
import { cert, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

export const FIREBASE_MESSAGING = 'FIREBASE_MESSAGING';

export const firebaseMessagingProvider = {
  provide: FIREBASE_MESSAGING,
  useFactory: () =>
    getMessaging(initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // .env stores the key's newlines as \n
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      }),
    })),
};
```

**`notifications.module.ts`**: add `firebaseMessagingProvider` to `providers`.

**`notifications.service.ts`**: inject messaging, push from `create()`, and save tokens:

```ts
import { Inject, Injectable, Logger } from '@nestjs/common';
import { Messaging } from 'firebase-admin/messaging';
import { FIREBASE_MESSAGING } from './firebase.provider.js';

  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @Inject(SUPABASE) private db: SupabaseClient,
    @Inject(FIREBASE_MESSAGING) private messaging: Messaging,
  ) {}

  async create(fromUser: string, toUser: string, title: string, description: string) {
    // ...existing insert...
    if (error) throw error;
    await this.push(toUser, title, description);
    return data;
  }

  // saves this device's FCM token for the user; the same token twice just refreshes updated_at
  async registerDeviceToken(userId: string, token: string) {
    const { error } = await this.db
      .from('device_tokens')
      .upsert({ user_id: userId, token, updated_at: new Date().toISOString() }, { onConflict: 'user_id,token' });
    if (error) throw error;
    return true;
  }

  // sends the notification to every device the user is signed in on;
  // a failed push is only logged, since the notification is already saved
  private async push(userId: string, title: string, body: string) {
    try {
      const { data: rows, error } = await this.db.from('device_tokens').select('token').eq('user_id', userId);
      if (error) throw error;
      if (!rows.length) return;

      const tokens = rows.map((row) => row.token);
      const result = await this.messaging.sendEachForMulticast({ tokens, notification: { title, body } });

      // FCM rejects tokens from uninstalled apps or expired installs; drop them so they aren't retried
      const dead = tokens.filter((_, i) => {
        const code = result.responses[i].error?.code;
        return code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token';
      });
      if (dead.length) await this.db.from('device_tokens').delete().in('token', dead);
    } catch (e) {
      this.logger.warn(`Push to ${userId} failed: ${e}`);
    }
  }
```

**`notifications.resolver.ts`**: mutation for saving the token:

```ts
  @Mutation(() => Boolean)
  registerDeviceToken(@Args('token') token: string, @CurrentUser() userId: string) {
    return this.notificationsService.registerDeviceToken(userId, token);
  }
```

### Frontend

**`frontend/lib/core/push.dart`** (new):

```dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:KKB/providers/global/graphql_client.dart';

// runs on a separate isolate when a push arrives while the app is closed;
// the system tray already shows notification pushes, so there's nothing to do yet
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {}

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
```

**`frontend/lib/main.dart`**: uncomment the Firebase placeholder in `main()` and add the imports:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:KKB/firebase_options.dart';
import 'package:KKB/core/push.dart';
import 'package:KKB/providers/auth/current_user.dart';
```

Then make `MyApp` a `ConsumerStatefulWidget` that registers the token on sign-in (`fireImmediately` covers a session restored on app open):

```dart
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(currentUserProvider, (prev, user) {
      if (user != null && prev?.id != user.id) registerPushToken(ref);
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    // ...existing build body unchanged...
  }
}
```

## Known gaps

- **Foreground pushes:** on Android, a push that arrives while the app is open doesn't show a system notification. Needs `flutter_local_notifications` (or an in-app banner from `FirebaseMessaging.onMessage`).
- **Logout:** the device's token isn't removed, so after logging out that phone keeps getting the previous user's pushes. Fix: an `unregisterDeviceToken` mutation called on sign-out.
- **Emulators:** FCM needs Google Play services, so use an emulator image with the Play Store, or a real device.

## Problems hit along the way

| Problem | Cause | Fix |
| --- | --- | --- |
| `bash: firebase: command not found` | Firebase CLI not installed (it's separate from `flutterfire`) | `npm install -g firebase-tools` |
| No rows in `device_tokens` after signing in | `Firebase.initializeApp` in `main.dart` was still commented out, so `FirebaseMessaging.instance` threw and `push.dart` only logged `FCM token not registered` | Uncomment the `try { await Firebase.initializeApp(...) }` block, then do a full restart (not hot reload) |
| `bash: flutterfire: command not found` | `%LOCALAPPDATA%\Pub\Cache\bin` isn't on PATH, and Git Bash doesn't add `.bat` on its own (Dart only installs `flutterfire.bat`) | Git Bash: `export PATH="$PATH:$LOCALAPPDATA/Pub/Cache/bin"` then `flutterfire.bat configure`. Any shell: `dart pub global run flutterfire_cli:flutterfire configure` |
