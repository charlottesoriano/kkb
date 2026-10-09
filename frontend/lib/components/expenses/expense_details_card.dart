import 'package:KKB/components/expenses/add_expense_shared.dart';
import 'package:KKB/components/global/text_field.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';
import 'package:flutter/material.dart';

// description + amount inputs at the top of the add expense screen
class ExpenseDetailsCard extends StatelessWidget {
  const ExpenseDetailsCard({
    super.key,
    required this.descriptionController,
    required this.amountController,
    required this.onChanged,
  });

  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: expenseCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KKBTextField(
            label: 'Description',
            hintText: 'e.g. Drinks at Station 2',
            controller: descriptionController,
            backgroundColor: KKBColors.lightBackground,
            onChanged: (_) => onChanged(),
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
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [expenseAmountFormatter],
                  cursorColor: KKBColors.lightPrimary,
                  style: KKBTextStyles.displayXLarge.copyWith(color: KKBColors.lightTextPrimary),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: KKBTextStyles.displayXLarge.copyWith(color: KKBColors.lightBorder),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
