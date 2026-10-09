// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

final class NotificationsProvider
    extends $NotifierProvider<Notifications, List<Notification>> {
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Notification> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Notification>>(value),
    );
  }
}

String _$notificationsHash() => r'de252807d520ceb7e41dad46b840b1e2ae55c837';

abstract class _$Notifications extends $Notifier<List<Notification>> {
  List<Notification> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Notification>, List<Notification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Notification>, List<Notification>>,
              List<Notification>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
