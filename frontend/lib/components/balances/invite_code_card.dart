import 'package:KKB/components/balances/balances_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// group invite code with a copy-to-clipboard button
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: balanceCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite code', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                const SizedBox(height: 2),
                Text(inviteCode, style: KKBTextStyles.code.copyWith(color: KKBColors.lightTextPrimary)),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _copyInviteCode(context),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text('Copy', style: KKBTextStyles.buttonSmall),
            style: balanceOutlinedButtonStyle(),
          ),
        ],
      ),
    );
  }

  Future<void> _copyInviteCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
  }
}
