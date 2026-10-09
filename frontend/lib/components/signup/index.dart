import 'package:KKB/components/global/button.dart';
import 'package:KKB/components/global/card.dart';
import 'package:KKB/components/signin/google_badge.dart';
import 'package:KKB/core/auth.dart';
import 'package:KKB/core/router.dart';
import 'package:KKB/models/response_status.dart';
import 'package:KKB/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../const/colors.dart';

class SignupIndex extends ConsumerStatefulWidget {
  const SignupIndex({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupIndexState();
}

class _SignupIndexState extends ConsumerState<SignupIndex> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  // true once Clerk sent the verification code, the card then asks for it
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // the strength meter follows what is typed
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _password => _passwordController.text;
  bool get _hasLength => _password.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_password);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password);
  int get _strength => [_hasLength, _hasNumber, _hasUppercase].where((met) => met).length;

  // returns the first problem with the form, null when it can be submitted
  String? _validate() {
    if (_firstNameController.text.trim().isEmpty) return 'Please enter your first name.';
    if (!ref.read(authServiceProvider).validateEmail(_emailController.text.trim())) return 'Please enter a valid email.';
    if (_strength < 3) return 'Your password doesn\'t meet all the requirements yet.';
    return null;
  }

  Future<void> _onCreateAccount() async {
    FocusScope.of(context).unfocus();
    final problem = _validate();
    setState(() => _error = problem);
    if (problem != null) return;

    setState(() => _loading = true);
    final result = await ref.read(authServiceProvider).authSignUp(
      email: _emailController.text.trim(),
      password: _password,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.status) return _showError(result);
    if (result.body?['needsVerification'] == true) {
      setState(() => _verifying = true);
      return;
    }
    GoRouter.of(context).go(AppRoutes.groups);
  }

  Future<void> _onVerify() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code from your email.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });
    final result = await ref.read(authServiceProvider).authVerifyEmail(code);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.status) return _showError(result);
    GoRouter.of(context).go(AppRoutes.groups);
  }

  Future<void> _onResendCode() async {
    final result = await ref.read(authServiceProvider).authResendVerificationCode();
    if (!mounted) return;
    if (!result.status) return _showError(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? '')));
  }

  Future<void> _onGoogleSignUp() async {
    final result = await ref.read(authServiceProvider).authGoogleSignIn(context);
    if (!mounted) return;
    if (result.status) {
      GoRouter.of(context).go(AppRoutes.groups);
    } else {
      Helper.showErrorSnackBar(context, result.message);
    }
  }

  // Clerk errors are already shown by ClerkErrorListener, everything else goes in the card
  void _showError(ResponseStatus result) {
    if (result.body is Map && result.body['errorShown'] == true) return;
    setState(() => _error = result.message);
  }

  void _onBack() {
    if (_verifying) {
      setState(() {
        _verifying = false;
        _error = null;
        _codeController.clear();
      });
      return;
    }
    GoRouter.of(context).go(AppRoutes.login);
  }

  void _onSignIn() {
    GoRouter.of(context).go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _onBack,
                          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: KKBColors.lightTextPrimary),
                        ),
                        const _LogoCircles(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _verifying ? 'Verify your email' : 'Create your account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: KKBColors.lightTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _verifying
                          ? 'One last step before you start splitting.'
                          : 'Start splitting costs with your roommates and trip groups.',
                      style: TextStyle(fontSize: 15, color: KKBColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 20),
                    _verifying ? _buildVerifyCard() : _buildCard(),
                    if (!_verifying) ...[
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      KKBButton(label: 'Sign up with Google', isOutlined: true, leading: const GoogleBadge(), onPressed: _loading ? null : _onGoogleSignUp),
                      const SizedBox(height: 20),
                      _buildSignIn(),
                    ],
                    const Spacer(),
                    const SizedBox(height: 24),
                    Text(
                      'Secure sign-up by Clerk',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: KKBColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      radius: 24,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('First name'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _firstNameController,
                      hint: 'Maya',
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Last name'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _lastNameController,
                      hint: 'Santos',
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _label('Email'),
          const SizedBox(height: 8),
          _textField(
            controller: _emailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _label('Password'),
          const SizedBox(height: 8),
          _textField(
            controller: _passwordController,
            hint: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: KKBColors.lightTextSecondary,
                size: 22,
              ),
            ),
          ),
          if (_password.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildStrengthMeter(),
            const SizedBox(height: 10),
            _requirement('At least 5 characters', _hasLength),
            const SizedBox(height: 4),
            _requirement('Includes a number', _hasNumber),
            const SizedBox(height: 4),
            _requirement('Includes an uppercase letter', _hasUppercase),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            _errorText(),
          ],
          const SizedBox(height: 20),
          KKBButton(label: 'Create account', isLoading: _loading, onPressed: _onCreateAccount),
        ],
      ),
    );
  }

  Widget _buildVerifyCard() {
    return KKBCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      radius: 24,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14, color: KKBColors.lightTextSecondary),
              children: [
                const TextSpan(text: 'We sent a 6-digit code to '),
                TextSpan(
                  text: _emailController.text.trim(),
                  style: TextStyle(fontWeight: FontWeight.w700, color: KKBColors.lightTextPrimary),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label('Verification code'),
          const SizedBox(height: 8),
          _textField(
            controller: _codeController,
            hint: '123456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _errorText(),
          ],
          const SizedBox(height: 20),
          KKBButton(label: 'Verify email', isLoading: _loading, onPressed: _onVerify),
          const SizedBox(height: 16),
          Center(
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: KKBColors.lightTextSecondary),
                children: [
                  const TextSpan(text: 'Didn\'t get it? '),
                  _linkSpan('Resend code', _loading ? null : _onResendCode, fontSize: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthMeter() {
    final (label, color) = switch (_strength) {
      3 => ('Strong', KKBColors.lightTextSuccess),
      2 => ('Fair', KKBColors.lightPrimary),
      _ => ('Weak', KKBColors.lightTextError),
    };

    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < _strength ? color : KKBColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _requirement(String text, bool met) {
    final color = met ? KKBColors.lightTextSuccess : KKBColors.lightTextSecondary;
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _errorText() {
    return Text(
      _error!,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KKBColors.lightTextError),
    );
  }

  Widget _buildDivider() {
    return Row(
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
    );
  }

  Widget _buildSignIn() {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 14, color: KKBColors.lightTextSecondary),
        children: [
          const TextSpan(text: 'Already have an account? '),
          _linkSpan('Sign in', _onSignIn),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  InlineSpan _linkSpan(String text, VoidCallback? onTap, {double fontSize = 14}) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: KKBColors.lightLink,
          ),
        ),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
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
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: !_loading,
      style: TextStyle(fontSize: 15, color: KKBColors.lightTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: KKBColors.lightTextSecondary.withValues(alpha: 0.6)),
        filled: true,
        fillColor: KKBColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
        enabledBorder: border(KKBColors.lightBorder),
        disabledBorder: border(KKBColors.lightBorder),
        focusedBorder: border(KKBColors.lightPrimary),
      ),
    );
  }
}

/// Small version of the brand circles, top right of the header.
class _LogoCircles extends StatelessWidget {
  const _LogoCircles();

  static const _size = 26.0;
  static const _overlap = 8.0;
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
