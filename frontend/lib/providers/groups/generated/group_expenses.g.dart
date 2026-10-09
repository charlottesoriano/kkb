// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../group_expenses.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GroupExpenses)
final groupExpensesProvider = GroupExpensesProvider._();

final class GroupExpensesProvider
    extends $NotifierProvider<GroupExpenses, List<Expense>> {
  GroupExpensesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupExpensesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupExpensesHash();

  @$internal
  @override
  GroupExpenses create() => GroupExpenses();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Expense> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Expense>>(value),
    );
  }
}

String _$groupExpensesHash() => r'5c260fa5148a33e7ac1373c81e330482041f31c5';

abstract class _$GroupExpenses extends $Notifier<List<Expense>> {
  List<Expense> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Expense>, List<Expense>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Expense>, List<Expense>>,
              List<Expense>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
