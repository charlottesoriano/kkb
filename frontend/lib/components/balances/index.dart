import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/global/tile_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/balance.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// one "X pays Y" suggestion from the simplified debts
typedef _SuggestedPayment = ({User from, User to, double amount});

class BalancesIndex extends ConsumerStatefulWidget {
  const BalancesIndex({super.key});

  @override
  ConsumerState<BalancesIndex> createState() => _BalancesIndexState();
}

class _BalancesIndexState extends ConsumerState<BalancesIndex> {
  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  // TODO: replace the static data below with the balances / group queries
  static const _maya = User(id: 'maya', email: '', displayName: 'Maya', firstName: 'Maya', lastName: 'Santos', imageUrl: '');
  static const _paolo = User(id: 'paolo', email: '', displayName: 'Paolo', firstName: 'Paolo', lastName: 'Reyes', imageUrl: '');
  static const _ines = User(id: 'ines', email: '', displayName: 'Ines', firstName: 'Ines', lastName: 'Cruz', imageUrl: '');
  static const _jun = User(id: 'jun', email: '', displayName: 'Jun', firstName: 'Jun', lastName: 'Dela Cruz', imageUrl: '');

  static const _members = [_maya, _paolo, _ines, _jun];
  static const _currentUserId = 'maya';
  static const _inviteCode = 'BORA-26';
  static const _paymentsWithoutSimplify = 6;

  // positive = gets back, negative = owes
  static const _balances = [
    Balance(user: _paolo, amount: 17062.50),
    Balance(user: _ines, amount: -3987.50),
    Balance(user: _maya, amount: -5337.50),
    Balance(user: _jun, amount: -7737.50),
  ];

  static const List<_SuggestedPayment> _suggestedPayments = [
    (from: _maya, to: _paolo, amount: 5337.50),
    (from: _jun, to: _paolo, amount: 7737.50),
    (from: _ines, to: _paolo, amount: 3987.50),
  ];

  bool _simplifyDebts = true;

  @override
  Widget build(BuildContext context) {
    // TODO: replace with the selected group once there's a provider for it
    final group = ref.watch(userGroupsProvider).firstOrNull;
    // TODO: use ref.watch(currentUserProvider)?.id once the static data is replaced
    const userId = _currentUserId;

    final myBalance = _balances.where((b) => b.user.id == userId).firstOrNull?.amount ?? 0;

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: group == null ? null : KKBGroupHeader(group: group, hasNotifications: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNetBalanceCard(myBalance),
            const SizedBox(height: 12),
            _buildInviteCodeCard(),
            const SizedBox(height: 12),
            KKBTileCard(
              title: 'Simplify debts',
              subtitle: '${_suggestedPayments.length} payments instead of $_paymentsWithoutSimplify',
              trailing: Switch(
                value: _simplifyDebts,
                activeThumbColor: KKBColors.lightOnPrimary,
                activeTrackColor: KKBColors.lightPrimary,
                onChanged: (value) => setState(() => _simplifyDebts = value),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Suggested payments'),
            const SizedBox(height: 10),
            Column(
              spacing: 12,
              children: [
                for (final payment in _suggestedPayments) _buildSuggestedPayment(payment, userId),
              ],
            ),
            const SizedBox(height: 20),

            _sectionLabel("Everyone's balance"),
            const SizedBox(height: 10),
            _buildEveryonesBalance(userId),
          ],
        ),
      ),
    );
  }

  Widget _buildNetBalanceCard(double balance) {
    final owedToYou = balance > 0 ? balance : 0.0;
    final youOwe = balance < 0 ? -balance : 0.0;
    final sign = balance < 0 ? '−' : balance > 0 ? '+' : '';
    final summary = switch (balance) {
      > 0 => "You're owed overall",
      < 0 => 'You owe overall',
      _ => 'All settled up',
    };

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: KKBColors.lightHero,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // decorative circles in the top-right corner
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(color: KKBColors.lightAvatar3, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: -14,
            right: 56,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: KKBColors.lightAvatar2, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your net balance',
                  style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightOnHero.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$sign${_currency.format(balance.abs())}',
                    style: KKBTextStyles.displayLarge.copyWith(color: KKBColors.lightOnHero),
                  ),
                ),
                const SizedBox(height: 6),
                Text(summary, style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightOnHero.withValues(alpha: 0.8))),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeroChip('Owed to you ${_currency.format(owedToYou)}'),
                    _buildHeroChip('You owe ${_currency.format(youOwe)}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KKBColors.lightOnHero.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightOnHero)),
    );
  }

  Widget _buildInviteCodeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite code', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                const SizedBox(height: 2),
                Text(_inviteCode, style: KKBTextStyles.code.copyWith(color: KKBColors.lightTextPrimary)),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _copyInviteCode,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text('Copy', style: KKBTextStyles.buttonSmall),
            style: _outlinedButtonStyle(),
          ),
        ],
      ),
    );
  }

  Future<void> _copyInviteCode() async {
    await Clipboard.setData(const ClipboardData(text: _inviteCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
  }

  Widget _buildSuggestedPayment(_SuggestedPayment payment, String userId) {
    final isMine = payment.from.id == userId;
    final title = isMine ? 'You pay ${payment.to.firstName}' : '${payment.from.firstName} pays ${payment.to.firstName}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        spacing: 10,
        children: [
          // from -> to
          Row(
            spacing: 4,
            children: [
              _buildMemberAvatar(payment.from),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: KKBColors.lightTextSecondary),
              _buildMemberAvatar(payment.to),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KKBTextStyles.bodySmallBold.copyWith(color: KKBColors.lightTextPrimary),
                ),
                Text(
                  isMine ? 'Pay to settle your balance' : 'Suggested payment',
                  style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6,
            children: [
              Text(
                _currency.format(payment.amount),
                style: KKBTextStyles.bodyMediumXBold.copyWith(
                  color: isMine ? KKBColors.lightOwe : KKBColors.lightTextPrimary,
                ),
              ),
              if (isMine)
                FilledButton(
                  onPressed: () => context.go(AppRoutes.settle),
                  style: FilledButton.styleFrom(
                    backgroundColor: KKBColors.lightPrimary,
                    foregroundColor: KKBColors.lightOnPrimary,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Settle up', style: KKBTextStyles.buttonSmall),
                )
              else
                OutlinedButton(
                  // TODO: send a reminder notification
                  onPressed: () {},
                  style: _outlinedButtonStyle(),
                  child: Text('Remind', style: KKBTextStyles.buttonSmall),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEveryonesBalance(String userId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < _balances.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: KKBColors.lightBorder),
            _buildBalanceRow(_balances[i], userId),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceRow(Balance balance, String userId) {
    final isMe = balance.user.id == userId;
    final (label, color, sign) = switch (balance.amount) {
      > 0 => ('gets back', KKBColors.lightOwed, '+'),
      < 0 => (isMe ? 'owe' : 'owes', KKBColors.lightOwe, '−'),
      _ => ('settled', KKBColors.lightTextSecondary, ''),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          _buildMemberAvatar(balance.user),
          Expanded(
            child: Text(
              isMe ? '${balance.user.firstName} (you)' : balance.user.firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyMediumSemiBold.copyWith(color: KKBColors.lightTextPrimary),
            ),
          ),
          Text(label, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
          Text(
            '$sign${_currency.format(balance.amount.abs())}',
            style: KKBTextStyles.bodyMediumXBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(User member, {double size = 32}) {
    final index = _members.indexWhere((m) => m.id == member.id);
    final (avatarColor, onAvatarColor) = _avatarColors[(index < 0 ? 0 : index) % _avatarColors.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Text(
        _initials('${member.firstName} ${member.lastName}'),
        style: KKBTextStyles.bodyXSmallBold.copyWith(color: onAvatarColor),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary));
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: KKBColors.lightTextPrimary,
      backgroundColor: KKBColors.lightSurface,
      side: const BorderSide(color: KKBColors.lightBorder),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  BoxDecoration _cardDecoration({double radius = 20}) {
    return BoxDecoration(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: KKBColors.lightBorder),
    );
  }

  // "Maya Santos" -> "MS"
  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1 || !RegExp(r'^[A-Za-z]').hasMatch(words[1])) {
      return words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
