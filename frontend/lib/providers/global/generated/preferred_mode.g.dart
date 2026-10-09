// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../preferred_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferredMode)
final preferredModeProvider = PreferredModeProvider._();

final class PreferredModeProvider
    extends $NotifierProvider<PreferredMode, String> {
  PreferredModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferredModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferredModeHash();

  @$internal
  @override
  PreferredMode create() => PreferredMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$preferredModeHash() => r'b129895428418c4c3e4276e8db47eb962e26fc15';

abstract class _$PreferredMode extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
