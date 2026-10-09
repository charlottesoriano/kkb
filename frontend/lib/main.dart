import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/env.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/providers/global/preferred_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:KKB/firebase_options.dart';
import 'package:KKB/core/push.dart';
import 'package:KKB/providers/auth/current_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (must be listed under flutter: assets: in pubspec.yaml)
  await dotenv.load(fileName: '.env');

  // Create the Clerk auth state once. Clerk restores the saved session here,
  // so a returning user is already signed in when the app opens.
  final clerk = await ClerkAuthState.create(
    config: ClerkAuthConfig(publishableKey: Env.clerkPublishableKey),
  );

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  } catch (e) {
    debugPrint('FCM disabled: $e');
  }
  

  runApp(
    ProviderScope(
      overrides: [clerkProvider.overrideWithValue(clerk)],
      child: const MyApp(),
    ),
  );
}

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
    final router = ref.watch(routerProvider);
    final clerk = ref.read(clerkProvider);
    final preferredMode = ref.watch(preferredModeProvider);

    return MaterialApp.router(
      title: 'KKB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: KKBColors.lightPrimary,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: KKBColors.darkPrimary,
        brightness: Brightness.dark,
      ),
      themeMode: preferredMode == 'light' ? ThemeMode.light : ThemeMode.dark,
      routerConfig: router,
      // Login vs app screens are handled by the router's redirect (core/router.dart).
      // ClerkErrorListener shows Clerk errors as snackbars.
      builder: (context, child) => ClerkAuth(
        authState: clerk,
        child: ClerkErrorListener(child: child!),
      ),
    );
  }
}