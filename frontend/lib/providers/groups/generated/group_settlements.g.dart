// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group_settlements.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupSettlements)
final groupSettlementsProvider = GroupSettlementsFamily._();

final class GroupSettlementsProvider
    extends $NotifierProvider<GroupSettlements, List<Settlement>> {
  GroupSettlementsProvider._({
    required GroupSettlementsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'groupSettlementsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupSettlementsHash();

  @override
  String toString() {
    return r'groupSettlementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GroupSettlements create() => GroupSettlements();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Settlement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Settlement>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupSettlementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupSettlementsHash() => r'9cd11d9e0659c544b6f1675bdec816eb14cfb5f1';

final class GroupSettlementsFamily extends $Family
    with
        $ClassFamilyOverride<
          GroupSettlements,
          List<Settlement>,
          List<Settlement>,
          List<Settlement>,
          int
        > {
  GroupSettlementsFamily._()
    : super(
        retry: null,
        name: r'groupSettlementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  GroupSettlementsProvider call(int groupId) =>
      GroupSettlementsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupSettlementsProvider';
}

abstract class _$GroupSettlements extends $Notifier<List<Settlement>> {
  late final _$args = ref.$arg as int;
  int get groupId => _$args;

  List<Settlement> build(int groupId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Settlement>, List<Settlement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Settlement>, List<Settlement>>,
              List<Settlement>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
