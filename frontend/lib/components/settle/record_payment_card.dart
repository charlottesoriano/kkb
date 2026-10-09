import 'package:KKB/components/settle/settle_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/models/settlement_input.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/group_expenses.dart';
import 'package:KKB/providers/groups/group_settlements.dart';
import 'package:KKB/providers/groups/selected_group.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// form for recording a payment from the current user to another member
class RecordPaymentCard extends ConsumerStatefulWidget {
  const RecordPaymentCard({super.key, required this.members, required this.userId});

  final List<User> members;
  final String userId;

  @override
  ConsumerState<RecordPaymentCard> createState() => _RecordPaymentCardState();
}

class _RecordPaymentCardState extends ConsumerState<RecordPaymentCard> {
  final _amountController = TextEditingController();
  String? _fromId;
  String? _toId;
  // the from/to pair the amount was last filled for, so it only refills when the pair changes
  String? _prefilledPair;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // default to "you pay"; the to side defaults to the first member you owe, in build
    _fromId = widget.members.where((m) => m.id == widget.userId).firstOrNull?.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _memberName(User member) => member.id == widget.userId ? '${member.firstName} (you)' : member.firstName;

  // how much [fromId] owes each other member, netted per pair:
  // their split shares on expenses the other paid, minus the other's shares on expenses they paid,
  // minus paid settlements they sent to the other, plus paid settlements the other sent them
  Map<String, double> _debtsOf(String fromId) {
    final debts = <String, double>{};
    final group = ref.watch(selectedGroupProvider);
    if (group == null) return debts;
    for (final expense in ref.watch(groupExpensesProvider)) {
      final payerId = expense.paidBy.id;
      for (final split in expense.splits) {
        if (split.user.id == payerId) continue;
        if (split.user.id == fromId) debts[payerId] = (debts[payerId] ?? 0) + split.amount;
        if (payerId == fromId) debts[split.user.id] = (debts[split.user.id] ?? 0) - split.amount;
      }
    }
    for (final settlement in ref.watch(groupSettlementsProvider(group.id))) {
      if (settlement.status != 'paid') continue;
      if (settlement.fromUser.id == fromId) debts[settlement.toUser.id] = (debts[settlement.toUser.id] ?? 0) - settlement.amount;
      if (settlement.toUser.id == fromId) debts[settlement.fromUser.id] = (debts[settlement.fromUser.id] ?? 0) + settlement.amount;
    }
    return debts;
  }

  Future<void> _submit(String fromId, String toId, double amount) async {
    final group = ref.read(selectedGroupProvider);
    if (group == null) return;

    final settlementInput = SettlementInput(fromUser: fromId, toUser: toId, amount: double.parse(amount.toStringAsFixed(2)));

    setState(() => _submitting = true);
    ResponseStatus result = await ref.read(groupSettlementsProvider(group.id).notifier).recordPayment(settlementInput);
    if (mounted) setState(() => _submitting = false);

    if (result.status) {
      // the payment is pending, so the debt (and the prefilled amount) wouldn't change; clear it instead
      _amountController.clear();
      // drop focus from the amount field so the keyboard closes
      if (mounted && context.mounted) FocusScope.of(context).unfocus();
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Payment recorded'), backgroundColor: KKBColors.lightTextSuccess));
    } else {
      if (mounted && context.mounted) Helper.showErrorSnackBar(context, result.message, action: DbAction.insert);
    }
  }

  @override
  Widget build(BuildContext context) {
    // drop a selection if that member is no longer in the group
    final fromId = widget.members.any((m) => m.id == _fromId) ? _fromId : null;
    // only the members the from side still owes money to; under half a centavo counts as settled
    final debts = fromId == null ? <String, double>{} : _debtsOf(fromId);
    final toMembers = widget.members.where((m) => (debts[m.id] ?? 0) >= 0.005).toList();
    // keep the picked member if from still owes them, otherwise fall back to the first one they owe
    final toId = toMembers.any((m) => m.id == _toId) ? _toId : toMembers.firstOrNull?.id;
    final toName = widget.members.where((m) => m.id == toId).map(_memberName).firstOrNull ?? 'They';
    final owed = toId == null ? 0.0 : debts[toId] ?? 0;
    final fromBalance = fromId == widget.userId ? 'Your' : "${widget.members.where((m) => m.id == fromId).firstOrNull?.firstName ?? 'Their'}'s";
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final canSubmit = fromId != null && toId != null && amount > 0 && !_submitting;

    // fill the amount with what from owes to whenever the pair changes; the user can still edit it after.
    // done after the frame because changing the controller rebuilds the text field
    final pair = '$fromId|$toId';
    if (pair != _prefilledPair) {
      _prefilledPair = pair;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _amountController.text = toId == null ? '' : owed.toStringAsFixed(2);
      });
    }

    return SettleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record a payment', style: KKBTextStyles.titleMedium.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 14),
          Row(
            spacing: 8,
            children: [
              // anyone can pay; the to side only lists who they owe, so you can't pay yourself
              Expanded(
                child: _PartyBox(label: 'From', value: fromId, members: widget.members, memberName: _memberName, onChanged: (id) => setState(() => _fromId = id)),
              ),
              const Icon(Icons.arrow_forward, size: 18, color: KKBColors.lightTextSecondary),
              Expanded(
                child: _PartyBox(
                  label: 'To',
                  value: toId,
                  members: toMembers,
                  hint: fromId != null && toMembers.isEmpty ? 'Owes no one' : 'Select',
                  memberName: _memberName,
                  onChanged: (id) => setState(() => _toId = id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Amount', style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            // rebuild so the button enables/disables as the amount changes
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: KKBColors.lightPrimary,
            style: KKBTextStyles.amountInput.copyWith(color: KKBColors.lightTextPrimary),
            decoration: InputDecoration(
              prefixText: '₱',
              prefixStyle: KKBTextStyles.amountInput.copyWith(color: KKBColors.lightTextPrimary),
              filled: true,
              fillColor: KKBColors.lightBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: KKBColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: KKBColors.lightPrimary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('$toName will be asked to confirm this payment.', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          const SizedBox(height: 14),
          SettleButton(label: _submitting ? 'Recording…' : 'Record payment', height: 52, onPressed: canSubmit ? () => _submit(fromId, toId, amount) : null),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: KKBColors.lightChip, borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Icon(Icons.info_outline, size: 16, color: KKBColors.lightTextPrimary),
                Expanded(
                  child: Text('$fromBalance balance stays at ${settleCurrency.format(owed)} owed until $toName confirms.', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyBox extends StatelessWidget {
  const _PartyBox({required this.label, required this.value, required this.members, required this.memberName, required this.onChanged, this.hint = 'Select'});

  final String label;
  // selected member id
  final String? value;
  final List<User> members;
  // shown when nothing is selected
  final String hint;
  final String Function(User member) memberName;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
      decoration: BoxDecoration(
        color: KKBColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KKBColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              hint: Text(hint, style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextSecondary)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: KKBColors.lightTextSecondary),
              dropdownColor: KKBColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
              items: [
                for (final member in members)
                  DropdownMenuItem(
                    value: member.id,
                    child: Text(memberName(member), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
