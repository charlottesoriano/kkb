// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../selected_group.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedGroup)
final selectedGroupProvider = SelectedGroupProvider._();

final class SelectedGroupProvider
    extends $NotifierProvider<SelectedGroup, Group?> {
  SelectedGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedGroupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedGroupHash();

  @$internal
  @override
  SelectedGroup create() => SelectedGroup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Group? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Group?>(value),
    );
  }
}

String _$selectedGroupHash() => r'4179dde187c822f9d592bc34a11a41c74ed4ec69';

abstract class _$SelectedGroup extends $Notifier<Group?> {
  Group? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Group?, Group?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Group?, Group?>,
              Group?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
