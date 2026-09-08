import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/history_entry.dart';

/// Lịch sử tính toán, lưu bằng SharedPreferences dưới dạng một chuỗi JSON.
///
/// Đủ dùng ở quy mô [_maxItems] dòng. Nếu sau này cần phân trang hoặc tìm
/// kiếm thì đổi sang sqflite — chỉ phải thay phần thân, API giữ nguyên.
class HistoryProvider extends ChangeNotifier {
  /// Có hậu tố version: khi đổi cấu trúc dữ liệu thì đổi key, bản ghi cũ
  /// bị bỏ qua thay vì làm vỡ lúc parse.
  static const _key = 'nova_history_v1';
  static const _maxItems = 100;

  /// Đồng hồ hệ thống trên Windows chỉ chính xác tới ~1ms, nên hai lần bấm '='
  /// liên tiếp có thể cho cùng một microsecondsSinceEpoch. Thêm số đếm để id
  /// không bao giờ trùng — nếu trùng thì remove(id) sẽ xoá nhầm nhiều dòng.
  static int _seq = 0;

  final List<HistoryEntry> _items = [];

  /// Nối tiếp các lần ghi để hai lần bấm '=' liên tiếp không ghi chồng nhau.
  Future<void> _writeQueue = Future.value();

  List<HistoryEntry> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items
        ..clear()
        ..addAll(list.map(HistoryEntry.fromJson));
    } on Object catch (err) {
      // Dữ liệu hỏng hoặc sai schema -> bắt đầu lại từ rỗng.
      // Không để exception thoát ra ngoài vì load() thường được gọi
      // không await lúc khởi tạo provider.
      debugPrint('Không đọc được lịch sử: $err');
      _items.clear();
    } finally {
      notifyListeners();
    }
  }

  Future<void> add(String expression, double result) {
    _items.insert(
      0,
      HistoryEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
        expression: expression,
        result: result,
        time: DateTime.now(),
      ),
    );
    if (_items.length > _maxItems) _items.removeLast();
    notifyListeners();
    return _persist();
  }

  Future<void> remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    return _persist();
  }

  Future<void> clearAll() {
    _items.clear();
    notifyListeners();
    return _persist();
  }

  Future<void> _persist() {
    return _writeQueue = _writeQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    });
  }
}
