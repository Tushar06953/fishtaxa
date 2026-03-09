import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/scan_result.dart';

part 'history_provider.g.dart';

@riverpod
class ScanHistory extends _$ScanHistory {
  @override
  List<ScanResult> build() {
    try {
      final box = Hive.box<ScanResult>('scan_history');
      return box.values.toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }

  void add(ScanResult r) {
    try {
      final box = Hive.box<ScanResult>('scan_history');
      box.add(r);
    } catch (_) {}
    ref.invalidateSelf();
  }

  void clear() {
    try {
      final box = Hive.box<ScanResult>('scan_history');
      box.clear();
    } catch (_) {}
    ref.invalidateSelf();
  }

  void deleteAt(int index) {
    try {
      final box = Hive.box<ScanResult>('scan_history');
      final all = box.values.toList();
      // reversed index
      final actualIndex = all.length - 1 - index;
      if (actualIndex >= 0 && actualIndex < all.length) {
        box.deleteAt(actualIndex);
      }
    } catch (_) {}
    ref.invalidateSelf();
  }
}
