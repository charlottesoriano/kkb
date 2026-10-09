import 'package:KKB/components/global/button.dart';
import 'package:KKB/components/global/card.dart';
import 'package:KKB/components/signin/google_badge.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/components/signin/reset_password_dialog.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../const/colors.dart';

class SigninIndex extends ConsumerStatefulWidget {
  const SigninIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SigninIndexState();
}

class _SigninIndexState extends ConsumerState<SigninIndex> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    final authService = ref.read(authServiceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? problem;
    if (!authService.validateEmail(email)) {
      problem = 'Please enter a valid email.';
    } else if (password.isEmpty) {
      problem = 'Please enter your password.';
    }
    setState(() => _error = problem);
    if (problem != null) return;

    setState(() => _loading = true);
    final result = await authService.authLogin(email: email, password: password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.status) {
      GoRouter.of(context).go(AppRoutes.groups);
    } else if (!(result.body is Map && result.body['errorShown'] == true)) {
      // Clerk errors (e.g. wrong password) are already shown by ClerkErrorListener
      setState(() => _error = result.message);
    }
  }

  Future<void> _onGoogleSignIn() async {
    final result = await ref.read(authServiceProvider).authGoogleSignIn(context);
    if (!mounted) return;
    if (result.status) {
      GoRouter.of(context).go(AppRoutes.groups);
    } else {
      Helper.showErrorSnackBar(context, result.message);
    }
  }


  // emails a reset code to the address in the email field, then asks for the code and the new password
  Future<void> _onForgotPassword() async {
    FocusScope.of(context).unfocus();
    final authService = ref.read(authServiceProvider);
    final email = _emailController.text.trim();
    if (!authService.validateEmail(email)) {
      setState(() => _error = 'Enter your email above, then tap "Forgot password?".');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await authService.authStartPasswordReset(email);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!result.status) {
      if (!(result.body is Map && result.body['errorShown'] == true)) setState(() => _error = result.message);
      return;
    }

    final reset = await showDialog<bool>(context: context, builder: (_) => ResetPasswordDialog(email: email));
    if (reset == true && mounted) GoRouter.of(context).go(AppRoutes.groups);
  }

  void _onCreateAccount() {
    GoRouter.of(context).go(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 44),
                    const _LogoCircles(),
                    const SizedBox(height: 16),
                    Text(
                      'KKB',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: KKBColors.lightTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Split costs, not friendships.',
                      style: TextStyle(fontSize: 15, color: KKBColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 28),
                    _buildCard(),
                    const SizedBox(height: 28),
                    _buildCreateAccount()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return KKBCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      radius: 24,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: KKBColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to see who owes who.',
            style: TextStyle(fontSize: 14, color: KKBColors.lightTextSecondary),
          ),
          const SizedBox(height: 20),
          _label('Email'),
          const SizedBox(height: 8),
          _textField(
            controller: _emailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Password'),
              GestureDetector(
                onTap: _onForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KKBColors.lightLink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _textField(
            controller: _passwordController,
            hint: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: KKBColors.lightTextSecondary,
                size: 22,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KKBColors.lightTextError,
              ),
            ),
          ],
          const SizedBox(height: 20),
          KKBButton(label: 'Sign in', isLoading: _loading, onPressed: _onSignIn),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: KKBColors.lightBorder, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(fontSize: 13, color: KKBColors.lightTextSecondary),
                ),
              ),
              Expanded(child: Divider(color: KKBColors.lightBorder, thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),
          KKBButton(label: 'Continue with Google', isOutlined: true, leading: const GoogleBadge(), onPressed: _onGoogleSignIn),
        ],
      ),
    );
  }

  Widget _buildCreateAccount() {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, color: KKBColors.lightTextSecondary),
        children: [
          const TextSpan(text: 'New to KKB? '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: _onCreateAccount,
              child: Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: KKBColors.lightLink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KKBColors.lightTextPrimary,
      ),
    );
  }

  Widget _textField(
    {
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color),
        );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(fontSize: 15, color: KKBColors.lightTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: KKBColors.lightTextSecondary.withValues(alpha: 0.6)),
        filled: true,
        fillColor: KKBColors.lightBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
        enabledBorder: border(KKBColors.lightBorder),
        focusedBorder: border(KKBColors.lightPrimary),
      ),
    );
  }
}

/// The four overlapping brand circles above the app name.
class _LogoCircles extends StatelessWidget {
  const _LogoCircles();

  static const _size = 66.0;
  static const _overlap = 20.0;
  static const _colors = [
    KKBColors.lightCategory1,
    KKBColors.lightCategory2,
    KKBColors.lightCategory3,
    KKBColors.lightCategory4,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size * _colors.length - _overlap * (_colors.length - 1),
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < _colors.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
