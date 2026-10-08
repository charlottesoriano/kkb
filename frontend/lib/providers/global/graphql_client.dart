import 'package:KKB/core/env.dart';
import 'package:KKB/core/auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/graphql_client.g.dart';

@Riverpod(keepAlive: true)
GraphQLClient graphqlClient(Ref ref) {
  final httpLink = HttpLink(
    Env.apiUrl, // your ngrok URL + /graphql
    defaultHeaders: {'ngrok-skip-browser-warning': 'true'},
  );

  // Adds a fresh Clerk JWT to every request
  final authLink = AuthLink(getToken: () async {
    final res = await ref.read(authServiceProvider).authGetToken();
    return res.status ? 'Bearer ${res.body['token']}' : null;
  });

  return GraphQLClient(
    link: authLink.concat(httpLink),
    cache: GraphQLCache(),
  );
}