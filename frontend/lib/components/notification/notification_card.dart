import 'package:KKB/components/global/card.dart';
import 'package:KKB/components/global/member_avatar.dart';
import 'package:KKB/components/global/status_chip.dart';
import 'package:KKB/components/global/svg_icon.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/const/icons.dart';
import 'package:KKB/models/notification.dart' as model;
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification});

  final model.Notification notification;

  static final _timeFormat = DateFormat('h:mm a');
  static final _dateFormat = DateFormat('MMM d');

  // small badge on the avatar, picked from the notification title
  String get _badgeIcon {
    final title = notification.title.toLowerCase();
    if (title.contains('expense')) return KKBIcons.expenses;
    if (title.contains('reminder')) return KKBIcons.bell;
    if (title.contains('confirmed')) return KKBIcons.checkCircle;
    return KKBIcons.settle;
  }

  // Today · 2:15 PM / Yesterday · 6:40 PM / Oct 6 · 9:12 PM
  String get _timestamp {
    final createdAt = DateTime.tryParse(notification.createdAt)?.toLocal();
    if (createdAt == null) return '';
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(createdAt.year, createdAt.month, createdAt.day)).inDays;
    final day = days == 0 ? 'Today' : days == 1 ? 'Yesterday' : _dateFormat.format(createdAt);
    return '$day · ${_timeFormat.format(createdAt)}';
  }

  @override
  Widget build(BuildContext context) {
    final fromUser = notification.fromUser;
    final fromName = fromUser.firstName.isNotEmpty ? fromUser.firstName : fromUser.displayName;

    return KKBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // same sender keeps the same color
              MemberAvatar(user: fromUser, size: 40, colorIndex: fromUser.id.hashCode.abs()),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KKBColors.lightSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: KKBColors.lightBorder),
                  ),
                  child: SvgIcon(icon: _badgeIcon, size: 10, color: KKBColors.lightTextPrimary),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(notification.title, style: KKBTextStyles.bodyLargeBold.copyWith(color: KKBColors.lightTextPrimary)),
                Text(notification.description, style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(label: 'From $fromName'),
                    const StatusChip(label: 'To you'),
                    Text(_timestamp, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
