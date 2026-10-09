//global input component
// lib/src/widgets/kkb_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:KKB/const/colors.dart'; // KKBColors
import 'package:KKB/utils/text_styles.dart'; // MTextStyles

/// What kind of input this is. Controls keyboard, obscuring and default icons.
enum KKBInputType { text, email, number, password, search }

/// Global text input for KKB (search bar + all form fields).
///
/// - [prefixIcon] / [suffixIcon]: pass any widget, or leave null for none.
///   (Search gets a default magnifier + clear button, password gets a default
///   show/hide button. Set [useDefaultIcons] to false to turn those off.)
/// - [hintText]: placeholder, fully dynamic.
/// - [type]: text, email, number, password or search.
/// - Light/dark colors are picked automatically from the current theme.
class KKBTextField extends StatefulWidget {
  const KKBTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.type = KKBInputType.text,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.useDefaultIcons = true,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization,
    this.backgroundColor,
    this.textAlign = TextAlign.start,
    this.textStyle,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Only used when no [controller] is passed.
  final String? initialValue;

  final KKBInputType type;

  /// Label shown above the field (optional).
  final String? label;

  /// Placeholder inside the field.
  final String? hintText;

  final String? helperText;

  /// Forces the error state when not null (otherwise [validator] drives it).
  final String? errorText;

  /// Custom leading widget (e.g. `Icon(Icons.mail_outline)`). Null = none.
  final Widget? prefixIcon;

  /// Custom trailing widget. Null = default for the [type], or none.
  final Widget? suffixIcon;

  /// When true: search shows magnifier + clear, password shows the eye toggle.
  final bool useDefaultIcons;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;

  /// Overrides the keyboard that [type] would pick.
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;

  /// Overrides the field fill (e.g. white search bar on a cream screen).
  final Color? backgroundColor;

  /// e.g. TextAlign.end for amount inputs.
  final TextAlign textAlign;

  /// Overrides the typed text style (color still follows the theme).
  final TextStyle? textStyle;

  @override
  State<KKBTextField> createState() => _KKBTextFieldState();
}

class _KKBTextFieldState extends State<KKBTextField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  bool _obscure = true;

  bool get _isPassword => widget.type == KKBInputType.password;
  bool get _isSearch => widget.type == KKBInputType.search;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {}); // rebuild so the clear button can appear/hide
  }

  TextInputType get _keyboardType {
    if (widget.keyboardType != null) return widget.keyboardType!;
    switch (widget.type) {
      case KKBInputType.email:
        return TextInputType.emailAddress;
      case KKBInputType.number:
        return const TextInputType.numberWithOptions(decimal: true);
      case KKBInputType.password:
        return TextInputType.visiblePassword;
      case KKBInputType.search:
        return TextInputType.text;
      case KKBInputType.text:
        return TextInputType.text;
    }
  }

  Iterable<String>? get _autofillHints {
    if (widget.autofillHints != null) return widget.autofillHints;
    switch (widget.type) {
      case KKBInputType.email:
        return const [AutofillHints.email];
      case KKBInputType.password:
        return const [AutofillHints.password];
      default:
        return null;
    }
  }

  Widget? _buildPrefix(_Palette p) {
    Widget? icon = widget.prefixIcon;
    if (icon == null && widget.useDefaultIcons && _isSearch) {
      icon = const Icon(Icons.search_rounded);
    }
    if (icon == null) return null;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 10),
      child: IconTheme(
        data: IconThemeData(color: p.icon, size: 20),
        child: icon,
      ),
    );
  }

  Widget? _buildSuffix(_Palette p) {
    if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 16),
        child: IconTheme(
          data: IconThemeData(color: p.icon, size: 20),
          child: widget.suffixIcon!,
        ),
      );
    }
    if (!widget.useDefaultIcons) return null;

    if (_isPassword) {
      return IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: p.icon,
        ),
      );
    }
    if (_isSearch && _controller.text.isNotEmpty) {
      return IconButton(
        tooltip: 'Clear',
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        icon: Icon(Icons.close_rounded, size: 20, color: p.icon),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final radius = BorderRadius.circular(_isSearch ? 16 : 14);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    final fill = widget.backgroundColor ?? (_isSearch ? p.searchFill : p.fill);

    final field = TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _isPassword && _obscure,
      enableSuggestions: !_isPassword,
      autocorrect: !_isPassword && !_isSearch,
      keyboardType: _keyboardType,
      textInputAction: widget.textInputAction ??
          (_isSearch ? TextInputAction.search : TextInputAction.next),
      textCapitalization: widget.textCapitalization ??
          (widget.type == KKBInputType.text
              ? TextCapitalization.sentences
              : TextCapitalization.none),
      autofillHints: _autofillHints,
      inputFormatters: widget.inputFormatters,
      maxLines: _isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      cursorColor: p.focus,
      textAlign: widget.textAlign,
      style: (widget.textStyle ?? KKBTextStyles.bodyLarge).copyWith(
        color: widget.enabled ? p.text : p.text.withValues(alpha: 0.6),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: (widget.textStyle ?? KKBTextStyles.bodyLarge).copyWith(color: p.placeholder),
        helperText: widget.helperText,
        helperStyle: KKBTextStyles.bodyXSmall.copyWith(color: p.placeholder),
        errorText: widget.errorText,
        errorStyle: KKBTextStyles.bodyXSmall.copyWith(color: p.error),
        counterText: '',
        filled: true,
        fillColor: fill,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.maxLines > 1 ? 16 : 16,
        ),
        prefixIcon: _buildPrefix(p),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 20),
        suffixIcon: _buildSuffix(p),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 44),
        enabledBorder: border(p.border),
        disabledBorder: border(p.border),
        focusedBorder: border(p.focus, 2),
        errorBorder: border(p.error),
        focusedErrorBorder: border(p.error, 2),
      ),
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label!,
          style: KKBTextStyles.bodySmallSemiBold.copyWith(color: p.label),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

/// Resolves KKBColors for the current light/dark theme.
class _Palette {
  const _Palette({
    required this.fill,
    required this.searchFill,
    required this.border,
    required this.text,
    required this.placeholder,
    required this.icon,
    required this.focus,
    required this.error,
    required this.label,
  });

  final Color fill;
  final Color searchFill;
  final Color border;
  final Color text;
  final Color placeholder;
  final Color icon;
  final Color focus;
  final Color error;
  final Color label;

  static _Palette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const _Palette(
            fill: KKBColors.darkSurface,
            searchFill: KKBColors.darkSurface,
            border: KKBColors.darkBorder,
            text: KKBColors.darkTextPrimary,
            placeholder: KKBColors.darkTextSecondary,
            icon: KKBColors.darkTextPrimary,
            focus: KKBColors.darkPrimary,
            error: KKBColors.darkOwe,
            label: KKBColors.darkTextPrimary,
          )
        : const _Palette(
            fill: KKBColors.lightSurface,
            searchFill: KKBColors.lightSurface,
            border: KKBColors.lightBorder,
            text: KKBColors.lightTextPrimary,
            placeholder: KKBColors.lightTextSecondary,
            icon: KKBColors.lightTextPrimary,
            focus: KKBColors.lightPrimary,
            error: KKBColors.lightOwe,
            label: KKBColors.lightTextPrimary,
          );
  }
}