// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group_balances.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupBalances)
final groupBalancesProvider = GroupBalancesProvider._();

final class GroupBalancesProvider
    extends $NotifierProvider<GroupBalances, List<Balance>> {
  GroupBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupBalancesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupBalancesHash();

  @$internal
  @override
  GroupBalances create() => GroupBalances();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Balance> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Balance>>(value),
    );
  }
}

String _$groupBalancesHash() => r'd48b11b5cb5a46097ddf5d86500af2f88d8e4c5b';

abstract class _$GroupBalances extends $Notifier<List<Balance>> {
  List<Balance> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Balance>, List<Balance>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Balance>, List<Balance>>,
              List<Balance>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
