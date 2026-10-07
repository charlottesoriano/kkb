import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get clerkPublishableKey => _get('CLERK_PUBLISHABLE_KEY');
  static String get apiUrl => _get('API_URL');

  static String _get(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env');
    }
    return value;
  }
}