import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/components/expenses/custom_split.dart';
import 'package:KKB/components/expenses/equal_split.dart';
import 'package:KKB/components/expenses/expense_details_card.dart';
import 'package:KKB/components/expenses/split_type_toggle.dart';
import 'package:KKB/components/expenses/who_paid.dart';
import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/expense_input.dart';
import 'package:KKB/models/expense_split_input.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddExpensesIndex extends ConsumerStatefulWidget {
  const AddExpensesIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddExpensesIndexState();
}

class _AddExpensesIndexState extends ConsumerState<AddExpensesIndex> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  // one input per member for the custom amounts form
  late final Map<String, TextEditingController> _customControllers;

  SplitType _splitType = SplitType.equal;
  String? _paidById;
  // blocks double taps while the expense is being saved
  bool _submitting = false;

  // members ticked in "Split between" (the payer included)
  late final Set<String> _selectedIds;

  // the group's members, read once in initState so the controllers above always match them
  late final List<User> _members;

  // everyone who shares the bill = ticked members, the payer included
  List<User> get _splitMembers => _members.where((m) => _selectedIds.contains(m.id)).toList();

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  double get _equalShare => _splitMembers.isEmpty ? 0 : _amount / _splitMembers.length;

  double get _customTotal => _splitMembers.fold(0, (sum, m) => sum + (double.tryParse(_customControllers[m.id]!.text) ?? 0));

  bool get _canSubmit {
    if (_descriptionController.text.trim().isEmpty || _amount <= 0 || _splitMembers.isEmpty) {
      return false;
    }
    if (_splitType == SplitType.custom) {
      return (_customTotal - _amount).abs() < 0.01;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _members = ref.read(selectedGroupProvider)?.members.toList() ?? [];
    _customControllers = {for (final m in _members) m.id: TextEditingController()};
    _selectedIds = _members.map((m) => m.id).toSet();

    // default payer: the signed-in user if they're in the group, otherwise the first member
    final userId = ref.read(currentUserProvider)?.id;
    _paidById = _members.any((m) => m.id == userId) ? userId : _members.firstOrNull?.id;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final controller in _customControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final group = ref.read(selectedGroupProvider);
    final paidById = _paidById;
    if (group == null || paidById == null) return;

    // member id -> their share of the bill (the payer's own share included)
    final shares = {for (final m in _splitMembers) m.id: _splitType == SplitType.equal ? _equalShare : double.tryParse(_customControllers[m.id]!.text) ?? 0};

    // every member's share of the bill, stored as the expense's splits
    final splits = [
      for (final MapEntry(key: memberId, value: share) in shares.entries)
        if (share > 0) ExpenseSplitInput(userId: memberId, amount: double.parse(share.toStringAsFixed(2))),
    ];

    final expenseInput = ExpenseInput(groupId: group.id, paidBy: paidById, description: _descriptionController.text.trim(), amount: _amount, splits: splits);

    setState(() => _submitting = true);
    ResponseStatus result = await ref.read(groupExpensesProvider.notifier).createExpense(expenseInput);
    if (mounted) setState(() => _submitting = false);

    if (result.status) {
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Expense added successfully'), backgroundColor: KKBColors.lightTextSuccess));
      if (mounted && context.mounted) context.canPop() ? context.pop() : context.go(AppRoutes.groupExpenses);
    } else {
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'An error occurred'), backgroundColor: KKBColors.lightTextError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: KKBGroupHeader(onTapGroup: () => context.go(AppRoutes.groupExpenses)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KKBTitle(title: 'Add expense'),
            const SizedBox(height: 16),
            ExpenseDetailsCard(descriptionController: _descriptionController, amountController: _amountController, onChanged: () => setState(() {})),
            const SizedBox(height: 20),

            const ExpenseSectionLabel('Who paid?'),
            const SizedBox(height: 10),
            WhoPaid(members: _members, paidById: _paidById, userId: userId, onSelect: (id) => setState(() => _paidById = id)),
            const SizedBox(height: 20),

            const ExpenseSectionLabel('Split type'),
            const SizedBox(height: 10),
            SplitTypeToggle(value: _splitType, onChanged: (type) => setState(() => _splitType = type)),
            const SizedBox(height: 20),

            if (_splitType == SplitType.equal)
              EqualSplit(
                members: _members,
                selectedIds: _selectedIds,
                equalShare: _equalShare,
                onToggle: (id) => setState(() => _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id)),
              )
            else
              CustomSplit(
                // only the members ticked in "Split between", so the inputs match what gets submitted
                members: _splitMembers,
                controllers: _customControllers,
                amount: _amount,
                assigned: _customTotal,
                onChanged: () => setState(() {}),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 8,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 18, color: KKBColors.lightTextSecondary),
                  Expanded(
                    child: Text('Everyone in the group gets a push notification when you add this.', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _canSubmit && !_submitting ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: KKBColors.lightPrimary,
                    foregroundColor: KKBColors.lightOnPrimary,
                    disabledBackgroundColor: KKBColors.lightPrimary.withValues(alpha: 0.4),
                    disabledForegroundColor: KKBColors.lightOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Add expense · ${expenseCurrency.format(_amount)}', style: KKBTextStyles.buttonLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
