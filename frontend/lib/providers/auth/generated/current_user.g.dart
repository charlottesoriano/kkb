// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../current_user.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentUser)
final currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider
    extends $NotifierProvider<CurrentUser, clerk_auth.User?> {
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(clerk_auth.User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<clerk_auth.User?>(value),
    );
  }
}

String _$currentUserHash() => r'efce1cf1c9239aa1967105184f308bbafdae785c';

abstract class _$CurrentUser extends $Notifier<clerk_auth.User?> {
  clerk_auth.User? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<clerk_auth.User?, clerk_auth.User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<clerk_auth.User?, clerk_auth.User?>,
              clerk_auth.User?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
