import 'package:KKB/const/colors.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/utils/helper.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberAvatar extends ConsumerStatefulWidget {
  const MemberAvatar({super.key, required this.user});

  final User user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemberAvatarState();
}

class _MemberAvatarState extends ConsumerState<MemberAvatar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KKBColors.lightAvatar1,
        shape: BoxShape.circle,
        // white ring separates overlapping circles
        border: Border.all(color: KKBColors.lightSurface, width: 2),
      ),
      child: widget.user.imageUrl.isEmpty
          ? _initials()
          : ClipOval(
              child: Image.network(
                widget.user.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                // fall back to initials if the image fails to load
                errorBuilder: (context, error, stackTrace) => _initials(),
              ),
            ),
    );
  }

  Widget _initials() {
    return Text(Helper.initials(widget.user.displayName), style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightOnAvatar1));
  }
}