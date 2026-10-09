import 'package:flutter/services.dart';

// shared pieces used by the add expense screen and its sections

enum SplitType { equal, custom }

// digits with at most 2 decimals, e.g. "3600" or "3600.50"
final expenseAmountFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));
