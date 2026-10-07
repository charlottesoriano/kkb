import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:KKB/models/response_status.dart';
import 'package:flutter/material.dart';


class AuthService {
  AuthService(this._clerk);

  final ClerkAuthState _clerk;

  Future<ResponseStatus> authLogin({
    required String email,
    required String password,
  }) async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};
    try {
      await _clerk.attemptSignIn(
        strategy: Strategy.password,
        identifier: email,
        password: password,
      );

      status = _clerk.isSignedIn;
      message = _clerk.isSignedIn ? 'Login Successful' : 'Login incomplete';
      body = _userBody();
    } catch (e) {
      message = _messageFromError(e);
      status = false;
    }
    statusResponse = ResponseStatus(message: message, status: status, body: body);

    return statusResponse;
  }

  Future<ResponseStatus> authSignUp({
    required String email,
    required String password,
    required String firstName,
  }) async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};

    try {
      await _clerk.attemptSignUp(
        strategy: Strategy.password,
        emailAddress: email,
        password: password,
        passwordConfirmation: password,
        firstName: firstName,
      );

      status = true;
      if (_clerk.isSignedIn) {
        message = 'Sign up Successful';
        body = _userBody();
      } else {
        // Clerk app requires email verification
        message = 'Check your email for a verification code';
        body = {'needsVerification': true};
      }
    } catch (e) {
      message = _messageFromError(e);
      status = false;
    }
    statusResponse = ResponseStatus(message: message, status: status, body: body);

    return statusResponse;
  }

  Future<ResponseStatus> authVerifyEmail(String code) async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};

    try {
      await _clerk.attemptSignUp(strategy: Strategy.emailCode, code: code); // verify name

      status = _clerk.isSignedIn;
      message = _clerk.isSignedIn ? 'Email verified' : 'Verification incomplete';
      body = _userBody();
    } catch (e) {
      message = _messageFromError(e);
      status = false;
    }
    statusResponse = ResponseStatus(message: message, status: status, body: body);

    return statusResponse;
  }

  /// Fresh JWT, body['token'] is what you send as "Bearer <token>"
  Future<ResponseStatus> authGetToken() async {
    ResponseStatus statusResponse = ResponseStatus(message: '', status: false, body: {});
    bool status = false;
    String message = '';
    dynamic body = {};

    try {
      if (!_clerk.isSignedIn) {
        message = 'Not signed in';
        status = false;
        body = {};
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

    print('----> authGoogleSignIn clerk: ${_clerk}');

    if (!_clerk.isSignedIn) {
    try {
      print('----> authGoogleSignIn transfer');
      // New Google user: turn Clerk's 'transferable' sign-in into a sign-up.
      await _clerk.fetchApiResponse(
        '/client/sign_ups',
        params: {'transfer': true},
      );
      print('----> authGoogleSignIn transfer success');
      _clerk.update();
    } catch (e) {
      // Fails if there was nothing to transfer, e.g. the user closed the Google page.
      print('----> transfer failed: $e');
    }
  }

    print('----> authGoogleSignIn: $message');
    status = _clerk.isSignedIn;
    if (message.isEmpty) {
      message = status ? 'Login Successful' : 'Google sign-in cancelled';
      print('----> authGoogleSignIn message: $message');
    }
    body = _userBody();
    print('----> authGoogleSignIn body: $body');
    status = true;
  } catch (e) {
    print('----> authGoogleSignIn error: $e');
    message = _messageFromError(e);
  }
  return ResponseStatus(message: message, status: status, body: body);
}

}