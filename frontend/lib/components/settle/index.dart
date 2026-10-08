import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO: replace the static data below with settlement/balance providers once they exist
const _paidBy = [
  ('Paolo', 30000.0),
  ('Ines', 6950.0),
  ('Maya', 3600.0),
  ('Jun', 3200.0),
];
const _expenseCount = 5;

const _pending = (name: 'Jun', initials: 'JD', date: 'Oct 6', amount: 900.0);

const _history = [
  (from: 'Maya', to: 'Paolo', date: 'Oct 6', amount: 2000.0, status: 'paid'),
  (from: 'Jun', to: 'Maya', date: 'Oct 6', amount: 900.0, status: 'pending'),
  (from: 'Ines', to: 'Paolo', date: 'Oct 5', amount: 1500.0, status: 'rejected'),
];

final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

class SettleIndex extends ConsumerStatefulWidget {
  const SettleIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettleIndexState();
}

class _SettleIndexState extends ConsumerState<SettleIndex> {
  final _amountController = TextEditingController(text: '5,337.50');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: replace with the selected group once there's a provider for it
    final group = ref.watch(userGroupsProvider).firstOrNull;

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: group == null ? null : KKBGroupHeader(group: group),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text('Settle up', style: KKBTextStyles.headerMedium.copyWith(color: KKBColors.lightTextPrimary)),
            _buildSummaryCard(),
            _buildConfirmationCard(),
            _buildRecordPaymentCard(),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Group summary ─────────────────────────

  Widget _buildSummaryCard() {
    const barColors = [
      KKBColors.lightCategory3,
      KKBColors.lightCategory2,
      KKBColors.lightCategory1,
      KKBColors.lightCategory4,
    ];
    final total = _paidBy.fold(0.0, (sum, p) => sum + p.$2);
    final maxPaid = _paidBy.fold(0.0, (max, p) => p.$2 > max ? p.$2 : max);
    final share = _paidBy.isEmpty ? 0.0 : total / _paidBy.length;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Group summary', style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_currency.format(total), style: KKBTextStyles.displaySmall.copyWith(color: KKBColors.lightTextPrimary)),
          ),
          const SizedBox(height: 6),
          Text(
            '$_expenseCount expenses · equal share ${_currency.format(share)} each',
            style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
          ),
          const SizedBox(height: 16),
          Text('Paid by', style: KKBTextStyles.bodySmallBold.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 8),
          for (var i = 0; i < _paidBy.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaidByBar(
                name: _paidBy[i].$1,
                amount: _paidBy[i].$2,
                fraction: maxPaid == 0 ? 0 : _paidBy[i].$2 / maxPaid,
                color: barColors[i % barColors.length],
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── Needs your confirmation ─────────────────────────

  Widget _buildConfirmationCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Needs your confirmation', style: KKBTextStyles.titleXSmall.copyWith(color: KKBColors.lightTextPrimary)),
              const _Pill(label: '1 pending', background: KKBColors.lightOweBackground, foreground: KKBColors.lightOwe),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: KKBColors.lightHero, shape: BoxShape.circle),
                child: Text(_pending.initials, style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightOnHero)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_pending.name} says they paid you',
                      style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                    ),
                    Text(
                      '${_pending.date} · waiting for your reply',
                      style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              Text(_currency.format(_pending.amount), style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary)),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: _Button(label: 'Reject', filled: false, onPressed: () {}),
              ),
              Expanded(
                child: _Button(label: 'Confirm', onPressed: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Record a payment ─────────────────────────

  Widget _buildRecordPaymentCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Record a payment', style: KKBTextStyles.titleMedium.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 14),
          const Row(
            spacing: 8,
            children: [
              Expanded(child: _PartyBox(label: 'From', value: 'You (Maya)')),
              Icon(Icons.arrow_forward, size: 18, color: KKBColors.lightTextSecondary),
              Expanded(child: _PartyBox(label: 'To', value: 'Paolo')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Amount', style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
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
          Text(
            'Paolo will be asked to confirm this payment.',
            style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
          ),
          const SizedBox(height: 14),
          _Button(label: 'Record payment', height: 52, onPressed: () {}),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KKBColors.lightChip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const Icon(Icons.info_outline, size: 16, color: KKBColors.lightTextPrimary),
                Expanded(
                  child: Text(
                    'Your balance stays at ₱5,337.50 owed until Paolo confirms.',
                    style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Payment history ─────────────────────────

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text('Payment history', style: KKBTextStyles.titleSmall.copyWith(color: KKBColors.lightTextPrimary)),
        _Card(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < _history.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: KKBColors.lightBorder),
                _HistoryRow(entry: _history[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Private widgets ─────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: KKBColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KKBColors.lightBorder),
        boxShadow: [
          BoxShadow(color: KKBColors.lightTextPrimary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _PaidByBar extends StatelessWidget {
  const _PaidByBar({required this.name, required this.amount, required this.fraction, required this.color});

  final String name;
  final double amount;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
            Text(_currency.format(amount), style: KKBTextStyles.bodyXSmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            color: color,
            backgroundColor: KKBColors.lightSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PartyBox extends StatelessWidget {
  const _PartyBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: KKBColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KKBColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onPressed, this.filled = true, this.height = 48});

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final size = Size.fromHeight(height);

    if (!filled) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          shape: shape,
          side: const BorderSide(color: KKBColors.lightBorder),
          foregroundColor: KKBColors.lightTextPrimary,
          textStyle: KKBTextStyles.buttonMedium,
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: size,
        shape: shape,
        backgroundColor: KKBColors.lightPrimary,
        foregroundColor: KKBColors.lightOnPrimary,
        textStyle: KKBTextStyles.buttonLarge,
      ),
      child: Text(label),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: KKBTextStyles.labelSmallBold.copyWith(color: foreground)),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final ({String from, String to, String date, double amount, String status}) entry;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (entry.status) {
      'paid' => ('Paid', KKBColors.lightOwedBackground, KKBColors.lightOwed),
      'rejected' => ('Rejected', KKBColors.lightOweBackground, KKBColors.lightOwe),
      _ => ('Pending', KKBColors.lightChip, KKBColors.lightTextPrimary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.from} → ${entry.to}',
                  style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(entry.date, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(_currency.format(entry.amount), style: KKBTextStyles.bodyLargeXBold.copyWith(color: KKBColors.lightTextPrimary)),
              _Pill(label: label, background: background, foreground: foreground),
            ],
          ),
        ],
      ),
    );
  }
}
