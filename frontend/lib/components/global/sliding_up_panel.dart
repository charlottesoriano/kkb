import 'package:flutter/material.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

/// Opens [child] in a panel that slides up from the bottom of the screen.
///
/// The panel sizes itself to its content, can be dragged down to dismiss,
/// and moves up with the keyboard. Returns whatever is passed to
/// `Navigator.pop(context, value)` from inside the panel.
Future<T?> showKKBSlidingUpPanel<T>(
  BuildContext context, {
  String? title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: KKBColors.lightSurface,
    barrierColor: KKBColors.lightScrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => KKBSlidingUpPanel(title: title, child: child),
  );
}

class KKBSlidingUpPanel extends StatelessWidget {
  const KKBSlidingUpPanel({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KKBColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (title != null) ...[
                Text(title!, style: KKBTextStyles.headerXSmall.copyWith(color: KKBColors.lightTextPrimary)),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
