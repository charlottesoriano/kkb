import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/providers/global/preferred_mode.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsIndex extends ConsumerStatefulWidget {
  const SettingsIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsIndexState();
}

class _SettingsIndexState extends ConsumerState<SettingsIndex> {
  static const _appVersion = 'v1.0.0';

  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    // Grab the container up front: on success the router redirects to /login and this widget is disposed
    final container = ProviderScope.containerOf(context, listen: false);
    final response = await ref.read(authServiceProvider).authLogout();

    if (response.status) {
      // These are keepAlive, so clear them or the next user sees this user's groups / cached queries
      container.invalidate(userGroupsProvider);
      container.invalidate(graphqlClientProvider);
      return;
    }

    if (mounted) {
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message ?? 'Could not log out')));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This removes your profile and shares from every group. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: KKBColors.lightOwe)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // TODO: call the delete account mutation, then log out
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(preferredModeProvider) == 'dark';
    final groups = ref.watch(userGroupsProvider);
    final userInfo = ref.read(authServiceProvider).authFetchUserInfo().body as Map<String, dynamic>;

    final background = isDark ? KKBColors.darkBackground : KKBColors.lightBackground;
    final surface = isDark ? KKBColors.darkSurface : KKBColors.lightSurface;
    final surfaceVariant = isDark ? KKBColors.darkSurfaceVariant : KKBColors.lightSurfaceVariant;
    final border = isDark ? KKBColors.darkBorder : KKBColors.lightBorder;
    final textPrimary = isDark ? KKBColors.darkTextPrimary : KKBColors.lightTextPrimary;
    final textSecondary = isDark ? KKBColors.darkTextSecondary : KKBColors.lightTextSecondary;
    final primary = isDark ? KKBColors.darkPrimary : KKBColors.lightPrimary;
    final onPrimary = isDark ? KKBColors.darkOnPrimary : KKBColors.lightOnPrimary;
    final danger = isDark ? KKBColors.darkOwe : KKBColors.lightOwe;

    final String userId = userInfo['id'] ?? '';
    final String firstName = userInfo['firstName'] ?? '';
    final String lastName = userInfo['lastName'] ?? '';
    final String email = userInfo['email'] ?? '';
    final displayName = '$firstName $lastName'.trim();
    final initials = [firstName, lastName].where((name) => name.isNotEmpty).map((name) => name[0].toUpperCase()).join();

    // Clerk doesn't give us created_at here, so borrow it from our own member record
    final me = groups.expand((group) => group.members).where((member) => member.id == userId).firstOrNull;
    final memberSince = DateTime.tryParse(me?.createdAt ?? '');
    final subtitle = [
      '${groups.length} ${groups.length == 1 ? 'group' : 'groups'}',
      if (memberSince != null) 'Member since ${_monthNames[memberSince.month - 1]} ${memberSince.year}',
    ].join(' · ');

    BoxDecoration card() => BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border),
    );

    Widget infoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: KKBTextStyles.bodyMedium.copyWith(color: textSecondary)),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                style: KKBTextStyles.bodyMediumBold.copyWith(color: textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget actionRow(IconData icon, String label, Color color, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            spacing: 12,
            children: [
              Icon(icon, color: color, size: 22),
              Text(label, style: KKBTextStyles.bodyLargeXBold.copyWith(color: color)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KKBTitle(title: 'Settings'),
              const SizedBox(height: 20),

              // profile card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: card(),
                child: Column(
                  children: [
                    Row(
                      spacing: 14,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: KKBColors.lightNotificationDot, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: primary,
                            child: Text(
                              initials,
                              style: KKBTextStyles.labelXSmall.copyWith(fontSize: 26, color: onPrimary),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(displayName, style: KKBTextStyles.titleLarge.copyWith(color: textPrimary)),
                              Text(email, style: KKBTextStyles.bodyMedium.copyWith(color: textSecondary), overflow: TextOverflow.ellipsis),
                              Text(subtitle, style: KKBTextStyles.bodyXSmall.copyWith(color: textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: [
                          infoRow('Display name', displayName),
                          Divider(height: 1, color: border),
                          infoRow('Email', email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: open edit profile
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: textPrimary,
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Edit profile', style: KKBTextStyles.buttonMedium),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // account actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: card(),
                child: Column(
                  children: [
                    actionRow(Icons.logout, 'Log out', textPrimary, _logout),
                    Divider(height: 1, color: border),
                    actionRow(Icons.delete_outline, 'Delete account', danger, _confirmDeleteAccount),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Deleting your account removes your profile and shares from every group. This can\'t be undone.',
                  style: KKBTextStyles.bodyXSmall.copyWith(color: textSecondary),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('KKB $_appVersion', style: KKBTextStyles.bodyXSmall.copyWith(color: textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
