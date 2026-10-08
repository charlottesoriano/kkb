import 'package:KKB/models/response_status.dart';
import 'package:KKB/providers/groups/user_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KKB/components/global/sliding_up_panel.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

/// Opens the "Join or create a group" panel.
Future<void> showJoinCreateGroupPanel(BuildContext context) {
  return showKKBSlidingUpPanel(
    context,
    title: 'Join or create a group',
    child: const JoinCreateGroupPanel(),
  );
}

class JoinCreateGroupPanel extends ConsumerStatefulWidget {
  const JoinCreateGroupPanel({super.key});

  @override
  ConsumerState<JoinCreateGroupPanel> createState() => _JoinCreateGroupPanelState();
}

class _JoinCreateGroupPanelState extends ConsumerState<JoinCreateGroupPanel> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onJoin() async {
    ResponseStatus result = await ref.read(userGroupsProvider.notifier).addMemberToGroup(_codeController.text);
    if (result.status) {      
      setState(() {
        _codeController.text = '';
      });
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Group joined successfully'), backgroundColor: KKBColors.lightTextSuccess));
      if(mounted && context.mounted) Navigator.pop(context);
    } else {
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'An error occurred'), backgroundColor: KKBColors.lightTextError));
    }
  }

  Future<void> _onCreate() async {
    if (_nameController.text.isEmpty) {
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group name is required'), backgroundColor: KKBColors.lightTextError));
      return;
    }
    if (_descriptionController.text.isEmpty) {
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Description is required'), backgroundColor: KKBColors.lightTextError));
      return;
    }

    ResponseStatus result = await ref.read(userGroupsProvider.notifier).createGroup(_nameController.text, _descriptionController.text);
    if (result.status) {
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Group created successfully'), backgroundColor: KKBColors.lightTextSuccess));
      if(mounted && context.mounted) Navigator.pop(context);
    } else {
      if(mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'An error occurred'), backgroundColor: KKBColors.lightTextError));
      setState(() {
        _nameController.text = '';
        _descriptionController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // join with a code
        Text('Join with a code', style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
        const SizedBox(height: 6),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: KKBTextField(
                controller: _codeController,
                hintText: 'BORA-26',
                backgroundColor: KKBColors.lightBackground,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onJoin(),
              ),
            ),
            SizedBox(
              height: 52,
              child: _PrimaryButton(label: 'Join', onPressed: _onJoin),
            ),
          ],
        ),

        // divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            spacing: 8,
            children: [
              const Expanded(child: Divider(color: KKBColors.lightBorder)),
              Text('or create a new one', style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary)),
              const Expanded(child: Divider(color: KKBColors.lightBorder)),
            ],
          ),
        ),

        // create a group
        KKBTextField(
          controller: _nameController,
          label: 'Group name',
          hintText: 'Palawan Getaway',
          backgroundColor: KKBColors.lightBackground,
        ),
        const SizedBox(height: 16),

        KKBTextField(
          controller: _descriptionController,
          label: 'Description',
          hintText: 'What is this group for?',
          backgroundColor: KKBColors.lightBackground,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 52,
          child: _PrimaryButton(label: 'Create group', onPressed: _onCreate),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: KKBColors.lightPrimary,
        foregroundColor: KKBColors.lightOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: KKBTextStyles.buttonMedium,
      ),
      child: Text(label),
    );
  }
}
