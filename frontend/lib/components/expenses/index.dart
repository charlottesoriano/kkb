import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// one expense split equally between [splitWith]
typedef _GroupExpense = ({int id, String description, User paidBy, double amount, DateTime date, List<User> splitWith});

class ExpensesIndex extends ConsumerStatefulWidget {
  const ExpensesIndex({super.key});

  @override
  ConsumerState<ExpensesIndex> createState() => _ExpensesIndexState();
}

class _ExpensesIndexState extends ConsumerState<ExpensesIndex> {
  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _shortDate = DateFormat('MMM d');

  // TODO: replace the static data below with the group expenses query
  static const _maya = User(id: 'maya', email: '', displayName: 'Maya', firstName: 'Maya', lastName: 'Santos', imageUrl: '');
  static const _paolo = User(id: 'paolo', email: '', displayName: 'Paolo', firstName: 'Paolo', lastName: 'Reyes', imageUrl: '');
  static const _ines = User(id: 'ines', email: '', displayName: 'Ines', firstName: 'Ines', lastName: 'Cruz', imageUrl: '');
  static const _jun = User(id: 'jun', email: '', displayName: 'Jun', firstName: 'Jun', lastName: 'Dela Cruz', imageUrl: '');

  static const _members = [_maya, _paolo, _ines, _jun];
  static const _currentUserId = 'maya';

  static final List<_GroupExpense> _expenses = [
    (id: 1, description: 'Drinks at Station 2', paidBy: _maya, amount: 3600, date: DateTime(2026, 10, 6), splitWith: _members),
    (id: 2, description: 'Seafood dinner', paidBy: _ines, amount: 6950, date: DateTime(2026, 10, 5), splitWith: _members),
    (id: 3, description: 'Boat transfers', paidBy: _jun, amount: 3200, date: DateTime(2026, 10, 5), splitWith: _members),
    (id: 4, description: 'Island hopping', paidBy: _paolo, amount: 6000, date: DateTime(2026, 10, 4), splitWith: _members),
    (id: 5, description: 'Beach villa', paidBy: _paolo, amount: 24000, date: DateTime(2026, 10, 3), splitWith: _members),
  ];

  // only one card is open at a time
  int? _expandedId;

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(selectedGroupProvider);
    // TODO: use ref.watch(currentUserProvider)?.id once the static data is replaced
    const userId = _currentUserId;

    final total = _expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: group == null ? null : KKBGroupHeader(group: group, hasNotifications: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expenses', style: KKBTextStyles.headerXSmall.copyWith(color: KKBColors.lightTextPrimary)),
            const SizedBox(height: 4),
            Text(
              '${_expenses.length} expenses · ${_currency.format(total)} total · tap one to see the split',
              style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
            ),
            const SizedBox(height: 16),
            if (_expenses.isEmpty)
              _buildEmptyState()
            else
              Column(
                spacing: 12,
                children: [
                  for (final expense in _expenses) _buildExpenseCard(expense, userId),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _openAddExpense,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Add expense', style: KKBTextStyles.buttonLarge),
              style: FilledButton.styleFrom(
                backgroundColor: KKBColors.lightPrimary,
                foregroundColor: KKBColors.lightOnPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAddExpense() {
    context.push(AppRoutes.addExpense);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Text(
        'No expenses yet. Add the first one!',
        textAlign: TextAlign.center,
        style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
      ),
    );
  }

  Widget _buildExpenseCard(_GroupExpense expense, String userId) {
    final expanded = _expandedId == expense.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _expandedId = expanded ? null : expense.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: _cardDecoration(borderColor: expanded ? KKBColors.lightPrimary : KKBColors.lightBorder),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                _buildExpenseSummary(expense, userId),
                if (expanded) ...[
                  const Divider(height: 1, color: KKBColors.lightBorder),
                  _buildSplitDetails(expense, userId),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseSummary(_GroupExpense expense, String userId) {
    final share = _shareOf(expense);
    final paidByMe = expense.paidBy.id == userId;
    final inSplit = expense.splitWith.any((m) => m.id == userId);

    // what this expense means for the signed-in user
    final (statusLabel, statusColor) = switch ((paidByMe, inSplit)) {
      (true, true) => ("You're owed ${_currency.format(expense.amount - share)}", KKBColors.lightOwed),
      (true, false) => ("You're owed ${_currency.format(expense.amount)}", KKBColors.lightOwed),
      (false, true) => ('You owe ${_currency.format(share)}', KKBColors.lightOwe),
      (false, false) => ('Not involved', KKBColors.lightTextSecondary),
    };

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        spacing: 12,
        children: [
          _buildMemberAvatar(expense.paidBy, size: 36),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodyMediumXBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(
                  'Paid by ${expense.paidBy.firstName} · ${_shortDate.format(expense.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency.format(expense.amount),
                style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary),
              ),
              Text(statusLabel, style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: statusColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitDetails(_GroupExpense expense, String userId) {
    final share = _shareOf(expense);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Split equally between ${expense.splitWith.length}',
                style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
              ),
              Text(
                '${_currency.format(share)} each',
                style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final member in expense.splitWith)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                spacing: 12,
                children: [
                  _buildMemberAvatar(member, size: 32),
                  Expanded(
                    child: Text(
                      member.id == userId ? '${member.firstName} (you)' : member.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KKBTextStyles.bodyMediumSemiBold.copyWith(color: KKBColors.lightTextPrimary),
                    ),
                  ),
                  if (member.id == expense.paidBy.id) _buildPaidChip(),
                  Text(
                    _currency.format(share),
                    style: KKBTextStyles.bodyMediumXBold.copyWith(color: KKBColors.lightTextPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaidChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KKBColors.lightChip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('Paid', style: KKBTextStyles.labelSmallBold.copyWith(color: KKBColors.lightTextPrimary)),
    );
  }

  double _shareOf(_GroupExpense expense) {
    return expense.splitWith.isEmpty ? 0 : expense.amount / expense.splitWith.length;
  }

  Widget _buildMemberAvatar(User member, {required double size}) {
    final index = _members.indexWhere((m) => m.id == member.id);
    final (avatarColor, onAvatarColor) = _avatarColors[(index < 0 ? 0 : index) % _avatarColors.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Text(
        Helper.initials('${member.firstName} ${member.lastName}'),
        style: KKBTextStyles.bodyXSmallBold.copyWith(color: onAvatarColor),
      ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 20, Color borderColor = KKBColors.lightBorder}) {
    return BoxDecoration(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
    );
  }
}
