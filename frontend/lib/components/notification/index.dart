import 'package:KKB/components/global/empty_state.dart';
import 'package:KKB/components/notification/notification_card.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/providers/global/notifications.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationIndex extends ConsumerStatefulWidget {
  const NotificationIndex({super.key});

  @override
  ConsumerState<NotificationIndex> createState() => _NotificationIndexState();
}

class _NotificationIndexState extends ConsumerState<NotificationIndex> {
  @override
  void initState() {
    super.initState();
    //refresh every time the screen opens so new notifications show up
    Future.microtask(() => ref.read(notificationsProvider.notifier).fetchUserNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: KKBColors.lightTextPrimary),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text('Notifications', style: KKBTextStyles.headerLarge.copyWith(color: KKBColors.lightTextPrimary)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: KKBColors.lightPrimary,
                onRefresh: () => ref.read(notificationsProvider.notifier).fetchUserNotifications(),
                child: notifications.isEmpty
                    // ListView so pull to refresh still works when empty
                    ? ListView(children: const [KKBEmptyState(title: 'No notifications yet', subtitle: 'Reminders and payment updates will show up here.')])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => NotificationCard(notification: notifications[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
