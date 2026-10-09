import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// hero card at the top of the balances screen with the current user's net balance
class NetBalanceCard extends StatelessWidget {
  const NetBalanceCard({super.key, required this.balance});

  // positive = gets back, negative = owes
  final double balance;

  @override
  Widget build(BuildContext context) {
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
                    '$sign${balanceCurrency.format(balance.abs())}',
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
                    _buildHeroChip('Owed to you ${balanceCurrency.format(owedToYou)}'),
                    _buildHeroChip('You owe ${balanceCurrency.format(youOwe)}'),
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
}
