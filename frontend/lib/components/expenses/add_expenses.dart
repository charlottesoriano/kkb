import 'package:KKB/components/global/group_header.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/components/global/title.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/models/group.dart';
import 'package:KKB/models/user.dart';
import 'package:KKB/providers/auth/current_user.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum SplitType { equal, custom }

class AddExpensesWidget extends ConsumerStatefulWidget {
  const AddExpensesWidget({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddExpensesWidgetState();
}

class _AddExpensesWidgetState extends ConsumerState<AddExpensesWidget> {
  static const _avatarColors = [
    (KKBColors.lightAvatar1, KKBColors.lightOnAvatar1),
    (KKBColors.lightAvatar2, KKBColors.lightOnAvatar2),
    (KKBColors.lightAvatar3, KKBColors.lightOnAvatar3),
    (KKBColors.lightAvatar4, KKBColors.lightOnAvatar4),
  ];

  static final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  // digits with at most 2 decimals, e.g. "3600" or "3600.50"
  static final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  // one input per member for the custom amounts form
  late final Map<String, TextEditingController> _customControllers = {
    for (final member in widget.group.members) member.id: TextEditingController(),
  };

  SplitType _splitType = SplitType.equal;
  String? _paidById;

  // members ticked in "Split between" (the payer is always left out, see _splitMembers)
  late final Set<String> _selectedIds = widget.group.members.map((m) => m.id).toSet();

  List<User> get _members => widget.group.members;

  // everyone who shares the bill = ticked members minus whoever paid
  List<User> get _splitMembers =>
      _members.where((m) => m.id != _paidById && _selectedIds.contains(m.id)).toList();

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  double get _equalShare => _splitMembers.isEmpty ? 0 : _amount / _splitMembers.length;

  double get _customTotal => _splitMembers.fold(
        0,
        (sum, m) => sum + (double.tryParse(_customControllers[m.id]!.text) ?? 0),
      );

  bool get _canSubmit {
    if (_descriptionController.text.trim().isEmpty || _amount <= 0 || _splitMembers.isEmpty) {
      return false;
    }
    if (_splitType == SplitType.custom) {
      return (_customTotal - _amount).abs() < 0.01;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // default payer: the signed-in user if they're in the group, otherwise the first member
    final userId = ref.read(currentUserProvider)?.id;
    _paidById = _members.any((m) => m.id == userId) ? userId : _members.firstOrNull?.id;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final controller in _customControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    // member id -> how much they owe the payer
    final shares = {
      for (final m in _splitMembers)
        m.id: _splitType == SplitType.equal
            ? _equalShare
            : double.tryParse(_customControllers[m.id]!.text) ?? 0,
    };
    // TODO: send to the create expense mutation
    debugPrint('---> add expense: ${_descriptionController.text} $_amount paid by $_paidById -> $shares');
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      backgroundColor: KKBColors.lightBackground,
      appBar: KKBGroupHeader(group: widget.group),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KKBTitle(title: 'Add expense'),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 20),

            _sectionLabel('Who paid?'),
            const SizedBox(height: 10),
            _buildWhoPaid(userId),
            const SizedBox(height: 20),

            _sectionLabel('Split type'),
            const SizedBox(height: 10),
            _buildSplitTypeToggle(),
            const SizedBox(height: 20),

            if (_splitType == SplitType.equal) _buildEqualSplit() else _buildCustomSplit(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 8,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 18, color: KKBColors.lightTextSecondary),
                  Expanded(
                    child: Text(
                      'Everyone in the group gets a push notification when you add this.',
                      style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: KKBColors.lightPrimary,
                    foregroundColor: KKBColors.lightOnPrimary,
                    disabledBackgroundColor: KKBColors.lightPrimary.withValues(alpha: 0.4),
                    disabledForegroundColor: KKBColors.lightOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Add expense · ${_currency.format(_amount)}',
                    style: KKBTextStyles.buttonLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KKBTextField(
            label: 'Description',
            hintText: 'e.g. Drinks at Station 2',
            controller: _descriptionController,
            backgroundColor: KKBColors.lightBackground,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Amount', style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('₱', style: KKBTextStyles.displaySmall.copyWith(color: KKBColors.lightTextSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_amountFormatter],
                  cursorColor: KKBColors.lightPrimary,
                  style: KKBTextStyles.displayXLarge.copyWith(color: KKBColors.lightTextPrimary),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: KKBTextStyles.displayXLarge.copyWith(color: KKBColors.lightBorder),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhoPaid(String? userId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 16,
        children: [
          for (final member in _members)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _paidById = member.id),
              child: SizedBox(
                width: 64,
                child: Column(
                  spacing: 6,
                  children: [
                    _buildMemberAvatar(member, size: 52, selected: member.id == _paidById),
                    Text(
                      member.id == userId ? '${member.firstName} (you)' : member.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: (member.id == _paidById ? KKBTextStyles.bodySmallBold : KKBTextStyles.bodySmall)
                          .copyWith(color: KKBColors.lightTextPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSplitTypeToggle() {
    Widget option(SplitType type, String label) {
      final selected = _splitType == type;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _splitType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? KKBColors.lightPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: (selected ? KKBTextStyles.bodyMediumBold : KKBTextStyles.bodyMedium).copyWith(
                color: selected ? KKBColors.lightOnPrimary : KKBColors.lightTextPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KKBColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          option(SplitType.equal, 'Equal'),
          option(SplitType.custom, 'Custom amounts'),
        ],
      ),
    );
  }

  Widget _buildEqualSplit() {
    final others = _members.where((m) => m.id != _paidById).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Split between'),
            Text(
              '${_currency.format(_equalShare)} each',
              style: KKBTextStyles.bodyXSmall.copyWith(color: KKBColors.lightTextSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: _cardDecoration(),
          child: others.isEmpty
              ? Text(
                  'No other members to split with.',
                  textAlign: TextAlign.center,
                  style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                )
              : Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  runSpacing: 16,
                  children: [
                    for (final member in others) _buildSplitMember(member),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSplitMember(User member) {
    final selected = _selectedIds.contains(member.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => selected ? _selectedIds.remove(member.id) : _selectedIds.add(member.id)),
      child: SizedBox(
        width: 72,
        child: Column(
          spacing: 6,
          children: [
            Opacity(
              opacity: selected ? 1 : 0.4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildMemberAvatar(member, size: 40),
                  if (selected)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: KKBColors.lightPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: KKBColors.lightSurface, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded, size: 12, color: KKBColors.lightOnPrimary),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              selected ? _currency.format(_equalShare) : '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KKBTextStyles.bodyXSmallBold.copyWith(color: KKBColors.lightTextPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSplit() {
    final others = _members.where((m) => m.id != _paidById).toList();
    final remaining = _amount - _customTotal;
    final balanced = remaining.abs() < 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Custom amounts'),
            Text(
              balanced
                  ? 'All assigned'
                  : remaining > 0
                      ? '${_currency.format(remaining)} left'
                      : '${_currency.format(remaining.abs())} over',
              style: KKBTextStyles.bodyXSmallBold.copyWith(
                color: balanced ? KKBColors.lightTextSuccess : KKBColors.lightTextError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: others.isEmpty
              ? Text(
                  'No other members to split with.',
                  textAlign: TextAlign.center,
                  style: KKBTextStyles.bodySmall.copyWith(color: KKBColors.lightTextSecondary),
                )
              : Column(
                  spacing: 12,
                  children: [
                    for (final member in others)
                      Row(
                        spacing: 12,
                        children: [
                          _buildMemberAvatar(member, size: 36),
                          Expanded(
                            child: Text(
                              '${member.firstName} ${member.lastName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: KKBTextStyles.bodyMediumSemiBold.copyWith(color: KKBColors.lightTextPrimary),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: KKBTextField(
                              type: KKBInputType.number,
                              hintText: '0.00',
                              controller: _customControllers[member.id],
                              inputFormatters: [_amountFormatter],
                              backgroundColor: KKBColors.lightBackground,
                              prefixIcon: Text(
                                '₱',
                                style: KKBTextStyles.bodyLargeBold.copyWith(color: KKBColors.lightTextSecondary),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(User member, {required double size, bool selected = false}) {
    final index = _members.indexWhere((m) => m.id == member.id);
    final (avatarColor, onAvatarColor) = _avatarColors[index % _avatarColors.length];

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColor, shape: BoxShape.circle),
      child: Text(
        _initials('${member.firstName} ${member.lastName}'),
        style: (size >= 48 ? KKBTextStyles.bodyMediumXBold : KKBTextStyles.bodyXSmallBold)
            .copyWith(color: onAvatarColor),
      ),
    );

    if (!selected) return circle;

    // payer ring: avatar -> white gap -> primary ring
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KKBColors.lightPrimary, width: 2),
      ),
      child: circle,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: KKBTextStyles.bodySmallSemiBold.copyWith(color: KKBColors.lightTextPrimary));
  }

  BoxDecoration _cardDecoration({double radius = 20}) {
    return BoxDecoration(
      color: KKBColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: KKBColors.lightBorder),
    );
  }

  // "Maya Santos" -> "MS"
  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1 || !RegExp(r'^[A-Za-z]').hasMatch(words[1])) {
      return words.first.substring(0, words.first.length.clamp(0, 2)).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
