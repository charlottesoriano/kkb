import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/providers/auth/auth_provider.dart';

// Holds the Clerk object. Its real value is supplied in main.dart.
final clerkProvider = Provider<ClerkAuthState>((ref) => throw UnimplementedError());

// Builds AuthService using that Clerk object.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(clerkProvider));
});