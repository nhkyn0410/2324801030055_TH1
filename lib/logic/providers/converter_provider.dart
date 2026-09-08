import 'package:flutter/foundation.dart';

import '../converters/unit_converter.dart';

/// Giữ trạng thái của màn hình Chuyển đổi: nhóm đơn vị, đơn vị nguồn/đích
/// và giá trị người dùng nhập.
class ConverterProvider extends ChangeNotifier {
  ConverterProvider() {
    _resetUnits();
  }

  UnitCategory _category = UnitCategory.length;
  late String _from;
  late String _to;
  String _rawInput = '';
  double _value = 0;
  String? _error;

  UnitCategory get category => _category;
  String get from => _from;
  String get to => _to;
  String get rawInput => _rawInput;
  String? get error => _error;

  List<UnitCategory> get categories => UnitCategory.values;
  List<String> get units => UnitConverter.unitsOf(_category);

  /// Kết quả quy đổi, hoặc `null` khi đầu vào chưa hợp lệ.
  double? get result {
    if (_error != null) return null;
    try {
      return UnitConverter.convert(
        category: _category,
        from: _from,
        to: _to,
        value: _value,
      );
    } on Object catch (err) {
      debugPrint('Lỗi quy đổi: $err');
      return null;
    }
  }

  void setCategory(UnitCategory c) {
    if (c == _category) return;
    _category = c;
    _resetUnits(); // đơn vị cũ không còn thuộc nhóm mới
    notifyListeners();
  }

  void setFrom(String unit) {
    if (!units.contains(unit) || unit == _from) return;
    _from = unit;
    notifyListeners();
  }

  void setTo(String unit) {
    if (!units.contains(unit) || unit == _to) return;
    _to = unit;
    notifyListeners();
  }

  void swap() {
    final tmp = _from;
    _from = _to;
    _to = tmp;
    notifyListeners();
  }

  void setInput(String text) {
    _rawInput = text;
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      _value = 0;
      _error = null;
    } else {
      final parsed = double.tryParse(trimmed.replaceAll(',', ''));
      if (parsed == null) {
        _error = 'Giá trị không hợp lệ';
      } else {
        _value = parsed;
        _error = null;
      }
    }
    notifyListeners();
  }

  void _resetUnits() {
    final u = units;
    _from = u.first;
    _to = u.length > 1 ? u[1] : u.first;
  }
}
