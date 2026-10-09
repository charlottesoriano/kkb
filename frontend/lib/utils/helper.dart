import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/expense.dart';
import 'package:KKB/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
    } catch (e) {
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

  static Color colorFromHex(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1 || !RegExp(r'^[A-Za-z]').hasMatch(words[1])) {
      return words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  static NumberFormat currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static String formatDate(String date, {String format = 'MMM d'}) {
    return DateFormat(format).format(DateTime.parse(date));
  }

  static double getUserBalance(Expense expense, String userId) {
    final userShare = expense.splits.where((split) => split.user.id == userId).fold<double>(0, (sum, split) => sum + split.amount);
    return expense.paidBy.id == userId ? expense.amount - userShare : -userShare;
  }

  static User parseUser(Map<String, dynamic>? data) {
    return User(id: data?['id'] ?? '', email: data?['email'] ?? '', displayName: data?['display_name'] ?? '', firstName: data?['first_name'] ?? '', lastName: data?['last_name'] ?? '');
  }
}
