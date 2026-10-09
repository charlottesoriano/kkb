import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/core/env.dart';

// GraphQL client for the NestJS backend. Every request carries the Clerk JWT.
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final clerk = ref.read(clerkProvider);
  final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : Env.apiUrl;
  final httpLink = HttpLink('$baseUrl/graphql');

  // Clerk tokens expire after about a minute, so ask for one on every request.
  // sessionToken() returns the cached token while it's still valid.
  final authLink = AuthLink(
    getToken: () async {
      if (!clerk.isSignedIn) return null;
      final token = await clerk.sessionToken();
      return 'Bearer ${token.jwt}';
    },
  );

  return GraphQLClient(
    link: authLink.concat(httpLink),
    cache: GraphQLCache(),
  );
});
