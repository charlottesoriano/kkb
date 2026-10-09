import 'package:clerk_auth/clerk_auth.dart' as clerk_auth;
import 'package:KKB/core/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/current_user.g.dart';

// The signed-in Clerk user, kept in sync with Clerk (login, logout, session restore).
@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  clerk_auth.User? build() {
    final clerk = ref.watch(clerkProvider);
    void listener() => state = clerk.user;
    clerk.addListener(listener);
    ref.onDispose(() => clerk.removeListener(listener));
    return clerk.user;
  }
}
