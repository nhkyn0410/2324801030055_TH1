import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/number_format.dart';

/// Bộ nhớ máy tính: MC / MR / M+ / M−.
///
/// Giá trị được ghi xuống đĩa nên không mất khi đóng app.
class MemoryProvider extends ChangeNotifier {
  static const _key = 'nova_memory_v1';

  double _value = 0;

  /// Nối tiếp các lần ghi. Nếu ghi song song thì M+ rồi M− có thể về đĩa
  /// sai thứ tự và giá trị cuối cùng bị sai.
  Future<void> _writeQueue = Future.value();

  double get value => _value;
  bool get hasValue => _value != 0;

  /// Chuỗi hiển thị trên chip trạng thái, ví dụ "M: 2,500".
  String get display => 'M: ${Num.format(_value)}';

  /// Hoàn tất khi mọi thay đổi đã được ghi xuống đĩa (dùng trong test).
  Future<void> get saved => _writeQueue;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _value = prefs.getDouble(_key) ?? 0;
    } on Object catch (err) {
      debugPrint('Không đọc được bộ nhớ: $err');
      _value = 0;
    } finally {
      notifyListeners();
    }
  }

  /// MC — xoá bộ nhớ.
  void clear() => _set(0);

  /// MR — lấy giá trị đang lưu.
  double recall() => _value;

  /// M+ — cộng dồn vào bộ nhớ.
  void add(double v) => _set(_value + v);

  /// M− — trừ khỏi bộ nhớ.
  void subtract(double v) => _set(_value - v);

  void _set(double v) {
    _value = v;
    notifyListeners();
    _writeQueue = _writeQueue.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_key, v);
      } on Object catch (err) {
        debugPrint('Không lưu được bộ nhớ: $err');
      }
    });
  }
}
