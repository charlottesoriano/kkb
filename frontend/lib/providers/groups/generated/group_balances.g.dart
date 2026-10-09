// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group_balances.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupBalances)
final groupBalancesProvider = GroupBalancesFamily._();

final class GroupBalancesProvider
    extends $NotifierProvider<GroupBalances, List<Balance>> {
  GroupBalancesProvider._({
    required GroupBalancesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'groupBalancesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupBalancesHash();

  @override
  String toString() {
    return r'groupBalancesProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is GroupBalancesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupBalancesHash() => r'6f1ea6b078a06bfa04b4a245f5304b527a0b52b6';

final class GroupBalancesFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupBalances,
          List<Balance>,
          List<Balance>,
          List<Balance>,
          int
        > {
  GroupBalancesFamily._()
    : super(
        retry: null,
        name: r'groupBalancesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GroupBalancesProvider call(int groupId) =>
      GroupBalancesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupBalancesProvider';
}

abstract class _$GroupBalances extends $Notifier<List<Balance>> {
  late final _$args = ref.$arg as int;
  int get groupId => _$args;

  List<Balance> build(int groupId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
