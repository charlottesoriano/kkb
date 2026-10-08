import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// Equal / Custom amounts segmented toggle
class SplitTypeToggle extends StatelessWidget {
  const SplitTypeToggle({super.key, required this.value, required this.onChanged});

  final SplitType value;
  final ValueChanged<SplitType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KKBColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _option(SplitType.equal, 'Equal'),
          _option(SplitType.custom, 'Custom amounts'),
        ],
      ),
    );
  }

  Widget _option(SplitType type, String label) {
    final selected = value == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(type),
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
}
