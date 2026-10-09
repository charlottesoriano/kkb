import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class AuthService {
  AuthService(this._clerk, this._ref);

  final ClerkAuthState _clerk;
  final Ref _ref;

  Future<ResponseStatus> authLogin({
    required String email,
    required String password,
  }) async {
    final error = await _clerkCall(() => _clerk.attemptSignIn(
      strategy: Strategy.password,
      identifier: email,
      password: password,
    ));
    if (error != null) return error;

    if (!_clerk.isSignedIn) return ResponseStatus(message: 'Login incomplete', status: false, body: {});
    return ResponseStatus(message: 'Login Successful', status: true, body: _userBody());
  }

  /// Manual sign up. body['needsVerification'] is true when Clerk sent a code to the email,
  /// finish with [authVerifyEmail]. Once signed in, the user is also created on the backend.
  Future<ResponseStatus> authSignUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final error = await _clerkCall(() async {
      await _clerk.attemptSignUp(
        strategy: Strategy.password,
        emailAddress: email,
        password: password,
        passwordConfirmation: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Clerk app requires email verification, this sends the code
      if (!_clerk.isSignedIn && _needsEmailVerification) {
        await _clerk.attemptSignUp(strategy: Strategy.emailCode);
      }
    });
    if (error != null) return error;

    if (_clerk.isSignedIn) return _syncBackendUser();
    if (_needsEmailVerification) {
      return ResponseStatus(message: 'Check your email for a verification code', status: true, body: {'needsVerification': true});
    }
    return ResponseStatus(message: 'Sign up incomplete', status: false, body: {});
  }

  Future<ResponseStatus> authVerifyEmail(String code) async {
    final error = await _clerkCall(() => _clerk.attemptSignUp(strategy: Strategy.emailCode, code: code));
    if (error != null) return error;

    if (!_clerk.isSignedIn) return ResponseStatus(message: 'Verification incomplete', status: false, body: {});
    return _syncBackendUser();
  }

  /// Sends a new verification code to the email of the pending sign up
  Future<ResponseStatus> authResendVerificationCode() async {
    final signUp = _clerk.client.signUp;
    if (signUp == null) return ResponseStatus(message: 'No sign up in progress', status: false, body: {});

    final error = await _clerkCall(() => _clerk.attemptSignUp(strategy: Strategy.emailCode, emailAddress: signUp.emailAddress));
    if (error != null) return error;
    return ResponseStatus(message: 'A new code was sent to your email', status: true, body: {});
  }

  bool get _needsEmailVerification => _clerk.client.signUp?.unverified(Field.emailAddress) == true;

  /// Creates the user on the backend. The Clerk user.created webhook does this too,
  /// but it can arrive after the app already needs the user (or never, if the webhook isn't reachable).
  Future<ResponseStatus> _syncBackendUser() => Helper.guard(() async {
    final client = _ref.read(graphqlClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(r'''
          mutation SyncUser {
            syncUser { id email display_name first_name last_name }
          }
        '''),
      )
    );

    if (result.hasException) {
      return ResponseStatus(message: Helper.error(result), status: false, body: {});
    }

    return ResponseStatus(message: 'Sign up Successful', status: true, body: result.data?['syncUser']);
  });

  /// ClerkErrorListener (main.dart) makes Clerk report errors on errorStream and show them
  /// as a snackbar instead of throwing, so listen for one here to know the call failed.
  /// Returns null on success. body['errorShown'] tells the screen not to show it a second time.
  Future<ResponseStatus?> _clerkCall(Future<void> Function() call) async {
    ClerkError? streamError;
    final sub = _clerk.errorStream.listen((e) => streamError ??= e);
    try {
      await call();
      await Future.delayed(Duration.zero); // let the broadcast stream deliver the error
    } catch (e) {
      return ResponseStatus(message: _messageFromError(e), status: false, body: {});
    } finally {
      await sub.cancel();
    }

    final error = streamError;
    if (error == null) return null;
    return ResponseStatus(message: _messageFromError(error), status: false, body: {'errorShown': true});
  }

  /// Fresh JWT, body['token'] is what you send as "Bearer <token>"
  Future<ResponseStatus> authGetToken() async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};

    try {
      if (!_clerk.isSignedIn) {
        return ResponseStatus(message: 'Not signed in', status: false, body: {});
      }
      final token = await _clerk.sessionToken();

      message = 'Token fetched';
      status = true;
      body = {'token': token.jwt};
    } catch (e) {
      message = _messageFromError(e);
      status = false;
    }
    statusResponse = ResponseStatus(message: message, status: status, body: body);

    return statusResponse;
  }

  ResponseStatus authFetchUserInfo() {
    bool signedIn = _clerk.isSignedIn;
    String message = '';
    dynamic body = {};
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    message = signedIn ? 'User information fetched' : 'Not signed in';
    body = _userBody();
    statusResponse = ResponseStatus(message: message, status: signedIn, body: body);
    return statusResponse;
  }

  Future<ResponseStatus> authLogout() async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};

    try {
      await _clerk.signOut();
      message = 'Logged out';
      status = true;
      body = {};
    } catch (e) {
      message = _messageFromError(e);
      status = false;
      body = {};
    }
    statusResponse = ResponseStatus(message: message, status: status, body: body);

    return statusResponse;
  }

  /// Map this into your own user model
  Map<String, dynamic> _userBody() {
    final user = _clerk.user;
    if (user == null) return {};
    return {
      'id': user.id,
      'email': user.email, // verify field names
      'firstName': user.firstName,
      'lastName': user.lastName,
    };
  }

  String _messageFromError(Object error) {
    if (error is ClerkError) {
      return error.message; // verify: field may be named differently
    }
    return error.toString();
  }

  bool validateEmail(String? value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return false;
    } else if (!regex.hasMatch(value)) {
      return false;
    }

    return true;
  }

  Future<ResponseStatus> authGoogleSignIn(BuildContext context) async {
  bool status = false;
  String message = '';
  dynamic body = {};

  try {
    await _clerk.ssoSignIn(
      context,
      Strategy.oauthGoogle,
      onError: (error) => message = _messageFromError(error),
    );


    if (!_clerk.isSignedIn) {
    try {
      // New Google user: turn Clerk's 'transferable' sign-in into a sign-up.
      await _clerk.fetchApiResponse(
        '/client/sign_ups',
        params: {'transfer': true},
      );
      _clerk.update();
    } catch (e) {
      // Fails if there was nothing to transfer, e.g. the user closed the Google page.
    }
  }

    status = _clerk.isSignedIn;
    if (message.isEmpty) {
      message = status ? 'Login Successful' : 'Google sign-in cancelled';
    }
    body = _userBody();

    // a first Google sign in is a sign up, make sure the backend has the user (existing users are left untouched)
    if (status) await _syncBackendUser();
  } catch (e) {
    message = _messageFromError(e);
  }
  return ResponseStatus(message: message, status: status, body: body);
}

}