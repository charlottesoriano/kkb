// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_groups.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserGroups)
final userGroupsProvider = UserGroupsProvider._();

final class UserGroupsProvider
    extends $NotifierProvider<UserGroups, List<Group>> {
  UserGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userGroupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userGroupsHash();

  @$internal
  @override
  UserGroups create() => UserGroups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Group> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Group>>(value),
    );
  }
}

String _$userGroupsHash() => r'f52e9392704a618b682f4b253f126e5ec7d1c734';

abstract class _$UserGroups extends $Notifier<List<Group>> {
  List<Group> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Group>, List<Group>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Group>, List<Group>>,
              List<Group>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
