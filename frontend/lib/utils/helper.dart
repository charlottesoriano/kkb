import 'dart:async';
import 'dart:io';

import 'package:KKB/models/response_status.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class Helper {
  Helper._();

  /// Turns any error object into a readable message.
  static String describe(Object e) => switch (e) {
    SocketException()      => 'No internet connection.',
    TimeoutException()     => 'Request timed out.',
    http.ClientException() => 'Could not reach the server.',
    FormatException()      => 'Unexpected response format.',
    // graphql link exceptions wrap the real cause, so unwrap and recurse
    NetworkException(:final originalException?)        => describe(originalException),
    UnknownException(:final originalException?)        => describe(originalException),
    ResponseFormatException(:final originalException?) => describe(originalException),
    Error()                => 'Unexpected error: $e',
    _                      => e.toString(),
  };

  /// Runs [call] and converts any thrown error into a failed [ResponseStatus].
  static Future<ResponseStatus> guard(Future<ResponseStatus> Function() call) async {
    try {
      return await call();
    } catch (e, stack) {
      debugPrint('---> Helper.guard caught: $e\n$stack');
      return ResponseStatus(message: describe(e), status: false, body: {});
    }
  }

  static String error(QueryResult result) {
    final e = result.exception;
    if (e == null) return 'Unknown error';
    if (e.graphqlErrors.isNotEmpty) return e.graphqlErrors.first.message;

    // Non-200 responses (e.g. 400 validation errors) land here, not in graphqlErrors
    final link = e.linkException;
    if (link is ServerException) {
      final errors = link.parsedResponse?.errors;
      if (errors != null && errors.isNotEmpty) return errors.first.message;
    }
    if (link != null) return describe(link);
    return 'Network error. Is the backend/ngrok running?';
  }
}
