import 'package:KKB/utils/helper.dart';
import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// one tappable member in the equal split: avatar with a check when selected + their share
class EqualSplitMember extends StatelessWidget {
  const EqualSplitMember({super.key, required this.member, required this.colorIndex, required this.selected, required this.equalShare, required this.onTap});

  final User member;
  final int colorIndex;
  final bool selected;
  final double equalShare;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          spacing: 6,
          children: [
            Opacity(
              opacity: selected ? 1 : 0.4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MemberAvatar(user: member, colorIndex: colorIndex, size: 40),
                  if (selected)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: KKBColors.lightPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: KKBColors.lightSurface, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded, size: 12, color: KKBColors.lightOnPrimary),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              selected ? Helper.currency.format(equalShare) : '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
