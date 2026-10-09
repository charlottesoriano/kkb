import 'package:KKB/core/auth.dart';
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


  void _onForgotPassword() {

  }

  void _onCreateAccount() {
    GoRouter.of(context).go(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _SigninColors(isDark);

    return Scaffold(
      backgroundColor: c.background,
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
                        color: c.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Split costs, not friendships.',
                      style: TextStyle(fontSize: 15, color: c.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    _buildCard(c),
                    const SizedBox(height: 28),
                    _buildCreateAccount(c)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_SigninColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to see who owes who.',
            style: TextStyle(fontSize: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 20),
          _label('Email', c),
          const SizedBox(height: 8),
          _textField(
            c,
            controller: _emailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Password', c),
              GestureDetector(
                onTap: _onForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.link,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _textField(
            c,
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
                color: c.textSecondary,
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
                color: c.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                disabledBackgroundColor: c.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: _loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: c.onPrimary),
                    )
                  : const Text('Sign in'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: c.border, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
              ),
              Expanded(child: Divider(color: c.border, thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _onGoogleSignIn,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textPrimary,
                backgroundColor: c.surface,
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: c.textPrimary, width: 1.2),
                    ),
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccount(_SigninColors c) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, color: c.textSecondary),
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
                  color: c.link,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, _SigninColors c) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      ),
    );
  }

  Widget _textField(
    _SigninColors c, {
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
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary.withValues(alpha: 0.6)),
        filled: true,
        fillColor: c.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
        enabledBorder: border(c.border),
        focusedBorder: border(c.primary),
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

class _SigninColors {
  _SigninColors(this.isDark);

  final bool isDark;

  Color get background =>
      isDark ? KKBColors.darkBackground : KKBColors.lightBackground;
  Color get surface => isDark ? KKBColors.darkSurface : KKBColors.lightSurface;
  Color get border => isDark ? KKBColors.darkBorder : KKBColors.lightBorder;
  Color get textPrimary =>
      isDark ? KKBColors.darkTextPrimary : KKBColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? KKBColors.darkTextSecondary : KKBColors.lightTextSecondary;
  Color get link => isDark ? KKBColors.darkLink : KKBColors.lightLink;
  Color get primary => isDark ? KKBColors.darkPrimary : KKBColors.lightPrimary;
  Color get onPrimary =>
      isDark ? KKBColors.darkOnPrimary : KKBColors.lightOnPrimary;
  Color get error => isDark ? KKBColors.darkOwe : KKBColors.lightTextError;
}
