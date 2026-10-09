import 'package:KKB/components/global/button.dart';
import 'package:KKB/components/global/card.dart';
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

  Future<void> copyInviteCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
  }
    return KKBCard(
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
          KKBButton(label: 'Copy', icon: Icons.copy_rounded, isOutlined: true, size: KKBButtonSize.small, onPressed: () => copyInviteCode(context)),
        ],
      ),
    );
  }
}
