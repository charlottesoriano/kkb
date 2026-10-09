import 'package:KKB/components/global/button.dart';
import 'package:KKB/components/global/card.dart';
import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/providers/global/graphql_client.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:KKB/providers/settings/user_profile.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:KKB/utils/helper.dart';
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
  bool _editing = false;
  bool _saving = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();

  // What we last saved, so the card updates right away (Clerk's user info won't reflect it until it refreshes)
  ({String firstName, String lastName, String displayName})? _savedProfile;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // Keeps the (disabled) inputs showing the current values whenever we're not editing
  void _syncControllers(String firstName, String lastName, String displayName) {
    if (_editing) return;
    if (_firstNameController.text != firstName) _firstNameController.text = firstName;
    if (_lastNameController.text != lastName) _lastNameController.text = lastName;
    if (_displayNameController.text != displayName) _displayNameController.text = displayName;
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    // dropping _editing lets the next build reset the inputs back to the current values
    setState(() => _editing = false);
  }

  Future<void> _saveProfile(String userId) async {
    if (_saving) return;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final typedDisplayName = _displayNameController.text.trim();
    final displayName = typedDisplayName.isEmpty ? '$firstName $lastName'.trim() : typedDisplayName;

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('First name is required')));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final response = await ref.read(userProfileSettingsProvider).updateUserProfile(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
    );
    if (!mounted) return;

    if (response.status) {
      setState(() {
        _saving = false;
        _editing = false;
        _savedProfile = (firstName: firstName, lastName: lastName, displayName: displayName);
      });
      // our member record (and its display name) comes from here
      ref.invalidate(userGroupsProvider);
    } else {
      setState(() => _saving = false);
      return Helper.showErrorSnackBar(context, response.message, action: DbAction.update);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message ?? 'Profile updated')));
  }

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
      Helper.showErrorSnackBar(context, response.message);
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
    final response = await ref.read(userProfileSettingsProvider).deleteUserProfile();
    if (response.status) {
      _logout();
    } else {
      if (mounted) Helper.showErrorSnackBar(context, response.message, action: DbAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(userGroupsProvider);
    final userInfo = ref.read(authServiceProvider).authFetchUserInfo().body as Map<String, dynamic>;


    final String userId = userInfo['id'] ?? '';
    final String email = userInfo['email'] ?? '';

    // Clerk doesn't give us created_at / display name here, so borrow them from our own member record
    final me = groups.expand((group) => group.members).where((member) => member.id == userId).firstOrNull;

    String pick(List<String?> values) => values.firstWhere((value) => value != null && value.isNotEmpty, orElse: () => '') ?? '';
    final firstName = pick([_savedProfile?.firstName, me?.firstName, userInfo['firstName']]);
    final lastName = pick([_savedProfile?.lastName, me?.lastName, userInfo['lastName']]);
    final displayName = pick([_savedProfile?.displayName, me?.displayName, '$firstName $lastName'.trim()]);
    final initials = [firstName, lastName].where((name) => name.isNotEmpty).map((name) => name[0].toUpperCase()).join();
    _syncControllers(firstName, lastName, displayName);
    final memberSince = DateTime.tryParse(me?.createdAt ?? '');
    final subtitle = [
      '${groups.length} ${groups.length == 1 ? 'group' : 'groups'}',
      if (memberSince != null) 'Member since ${_monthNames[memberSince.month - 1]} ${memberSince.year}',
    ].join(' · ');

    // label on the left, value on the right; the value is an input that only unlocks while editing
    Widget profileRow(String label, TextEditingController controller, {TextInputAction action = TextInputAction.next}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: _editing ? 6 : 14),
        child: Row(
          children: [
            Text(label, style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary)),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: _editing && !_saving,
                textAlign: TextAlign.right,
                textInputAction: action,
                textCapitalization: TextCapitalization.words,
                cursorColor: KKBColors.lightPrimary,
                style: KKBTextStyles.bodyMediumBold.copyWith(color: KKBColors.lightTextPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: _editing ? 8 : 0),
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: KKBColors.lightBorder)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: KKBColors.lightPrimary, width: 2)),
                ),
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
      backgroundColor: KKBColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KKBTitle(title: 'Settings'),
              const SizedBox(height: 20),

              // profile card
              KKBCard(
                padding: const EdgeInsets.all(16),
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
                            backgroundColor: KKBColors.lightPrimary,
                            child: Text(
                              initials,
                              style: KKBTextStyles.labelXSmall.copyWith(fontSize: 26, color: KKBColors.lightOnPrimary),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(displayName, style: KKBTextStyles.titleLarge.copyWith(color: KKBColors.lightTextPrimary)),
                              Text(email, style: KKBTextStyles.bodyMedium.copyWith(color: KKBColors.lightTextSecondary), overflow: TextOverflow.ellipsis),
                              Text(subtitle, style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: KKBColors.lightSurfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: KKBColors.lightBorder),
                      ),
                      child: Column(
                        children: [
                          profileRow('First name', _firstNameController),
                          Divider(height: 1, color: KKBColors.lightBorder),
                          profileRow('Last name', _lastNameController),
                          Divider(height: 1, color: KKBColors.lightBorder),
                          profileRow('Display name', _displayNameController, action: TextInputAction.done),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_editing)
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(child: KKBButton(label: 'Cancel', isOutlined: true, onPressed: _saving ? null : _cancelEdit)),
                          Expanded(child: KKBButton(label: 'Save', isLoading: _saving, onPressed: () => _saveProfile(userId))),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: KKBButton(label: 'Edit profile', isOutlined: true, onPressed: () => setState(() => _editing = true)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // account actions
              KKBCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    actionRow(Icons.logout, 'Log out', KKBColors.lightTextPrimary, _logout),
                    Divider(height: 1, color: KKBColors.lightBorder),
                    actionRow(Icons.delete_outline, 'Delete account', KKBColors.lightOwe, _confirmDeleteAccount),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Deleting your account removes your profile and shares from every group. This can\'t be undone.',
                  style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text('KKB $_appVersion', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
