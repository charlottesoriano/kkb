import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:KKB/utils/storage_helper.dart';

part 'generated/preferred_mode.g.dart';

@Riverpod(keepAlive: true)
class PreferredMode extends _$PreferredMode {
  @override
  String build() {
    return 'light';
  }

  Future<void> setPreferredMode(String mode) async {
    state = mode;
    await KKBStorageHelper.setPreferredMode(mode);
  }

  Future<void> getPreferredMode() async {
    state = await KKBStorageHelper.getPreferredMode();
  }
}