import 'package:KKB/core/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// second step of "Forgot password?": the code Clerk emailed plus the new password.
// pops true once the password is changed (Clerk signs the user in at that point)
class ResetPasswordDialog extends ConsumerStatefulWidget {
  const ResetPasswordDialog({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends ConsumerState<ResetPasswordDialog> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    if (code.length != 6) return setState(() => _error = 'Enter the 6-digit code from your email.');
    if (password.isEmpty) return setState(() => _error = 'Enter a new password.');

    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref.read(authServiceProvider).authResetPassword(email: widget.email, code: code, newPassword: password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.status) {
      Navigator.of(context).pop(true);
    } else if (!(result.body is Map && result.body['errorShown'] == true)) {
      // Clerk errors are already shown by ClerkErrorListener
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter the code sent to ${widget.email} and choose a new password.'),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Code', counterText: ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New password'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'Saving…' : 'Reset password')),
      ],
    );
  }
}
