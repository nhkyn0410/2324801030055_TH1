import 'package:flutter/foundation.dart';

import '../../core/utils/number_format.dart';
import '../engine/expression_evaluator.dart';

/// Giữ biểu thức đang nhập và kết quả xem trước.
///
/// Quy ước quan trọng: mọi giá trị đi RA ngoài ([lastValue], [equals]) đều là
/// [double] thô. Chỉ [result] là chuỗi và nó chỉ dùng để hiển thị.
class CalculatorProvider extends ChangeNotifier {
  static const _operators = {'+', '-', '−', '×', '÷', '*', '/', '^'};

  String _expression = '';
  String _result = '0';
  String? _error;
  double _lastValue = 0;
  bool _degrees = true;
  bool _justEvaluated = false;

  String get expression => _expression;

  /// Chuỗi đã format để hiển thị, ví dụ "11,075".
  String get result => _result;

  /// Giá trị số thô của [result] — dùng cho Memory (M+/M−) và History.
  double get lastValue => _lastValue;

  String? get error => _error;
  bool get degrees => _degrees;
  bool get isEmpty => _expression.isEmpty;

  /// Nhãn đơn vị góc hiển thị trên panel.
  String get angleUnit => _degrees ? 'DEG' : 'RAD';

  // ------------------------------------------------------------------ nhập

  void input(String token) {
    _error = null;

    // Sau khi bấm '=': gõ số/hàm thì bắt đầu biểu thức mới,
    // gõ toán tử thì tính tiếp trên kết quả vừa ra.
    if (_justEvaluated) {
      _justEvaluated = false;
      if (_startsNewEntry(token)) _expression = '';
    }

    final piece = _validate(token);
    if (piece == null) return; // đầu vào bị chặn, không làm gì

    _expression += piece;
    _previewResult();
    notifyListeners();
  }

  void backspace() {
    if (_expression.isEmpty) return;
    _justEvaluated = false;
    _error = null;
    _expression = _expression.substring(0, _expression.length - 1);
    _previewResult();
    notifyListeners();
  }

  void clearAll() {
    _expression = '';
    _result = '0';
    _lastValue = 0;
    _error = null;
    _justEvaluated = false;
    notifyListeners();
  }

  /// Đổi dấu SỐ ĐANG NHẬP, không phải cả biểu thức:
  /// `2+3` -> `2+-3` (= -1), bấm lại -> `2+3`.
  void toggleSign() {
    final m = RegExp(r'(\d+\.?\d*)$').firstMatch(_expression);
    if (m == null) return;

    var head = _expression.substring(0, m.start);
    final number = m.group(0)!;

    if (head.endsWith('-')) {
      final before = head.length >= 2 ? head[head.length - 2] : '';
      // Dấu '-' này là dấu âm (đứng đầu, sau toán tử hoặc sau '(') -> gỡ ra.
      if (head.length == 1 || _operators.contains(before) || before == '(') {
        head = head.substring(0, head.length - 1);
        _apply('$head$number');
        return;
      }
    }
    _apply('$head-$number');
  }

  void toggleAngleUnit() {
    _degrees = !_degrees;
    _previewResult();
    notifyListeners();
  }

  /// Nạp lại một biểu thức — dùng cho MR (Memory Recall) và
  /// Recalculate ở màn hình Lịch sử.
  void loadExpression(String expr) {
    _justEvaluated = false;
    _error = null;
    _apply(expr);
  }

  // ------------------------------------------------------------------ tính

  /// Trả về biểu thức đã dùng và giá trị thô để gọi bên ngoài ghi vào
  /// lịch sử; trả `null` nếu biểu thức lỗi.
  ({String expression, double value})? equals() {
    if (_expression.isEmpty) return null;
    try {
      final value = ExpressionEvaluator(degrees: _degrees).evaluate(_expression);
      final used = _expression;

      _lastValue = value;
      _result = Num.format(value);
      // Giữ số thô để tính tiếp không mất độ chính xác (KHÔNG giữ "11,075").
      _expression = value.toString();
      _error = null;
      _justEvaluated = true;
      notifyListeners();

      return (expression: used, value: value);
    } on FormatException catch (e) {
      _error = e.message;
      _result = 'Lỗi';
      _justEvaluated = false;
      notifyListeners();
      return null;
    }
  }

  // ----------------------------------------------------------------- riêng

  void _apply(String expr) {
    _expression = expr;
    _previewResult();
    notifyListeners();
  }

  void _previewResult() {
    if (_expression.isEmpty) {
      _result = '0';
      _lastValue = 0;
      return;
    }
    try {
      final value = ExpressionEvaluator(degrees: _degrees).evaluate(_expression);
      _lastValue = value;
      _result = Num.format(value);
    } on FormatException {
      // Biểu thức còn dở dang (ví dụ "5+") — giữ nguyên kết quả cũ và
      // không báo lỗi; lỗi chỉ hiện khi người dùng thực sự bấm '='.
    }
  }

  /// Sau khi bấm '=', token nào mở một biểu thức mới thay vì nối tiếp.
  bool _startsNewEntry(String token) =>
      !_operators.contains(token) &&
      token != ')' &&
      token != '!' &&
      token != '%';

  /// Trả về đoạn được phép nối thêm, hoặc `null` nếu đầu vào không hợp lệ.
  /// Có thể tự cắt bớt [_expression] khi cần thay toán tử.
  String? _validate(String token) {
    if (_operators.contains(token)) {
      if (_expression.isEmpty) {
        return token == '-' || token == '−' ? token : null;
      }
      final last = _expression[_expression.length - 1];

      if (_operators.contains(last)) {
        // Cho phép dấu âm sau ^ × ÷ : "2^-3", "5×-2"
        if ((token == '-' || token == '−') &&
            (last == '^' || last == '×' || last == '÷')) {
          return token;
        }
        // Còn lại: thay toán tử cũ bằng toán tử vừa bấm.
        _expression = _expression.substring(0, _expression.length - 1);
        return token;
      }
      if (last == '(') return token == '-' || token == '−' ? token : null;
      return token;
    }

    if (token == '.') {
      // Chặn dấu chấm thứ hai trong cùng một số.
      final tail = RegExp(r'[0-9.]*$').stringMatch(_expression) ?? '';
      if (tail.contains('.')) return null;
      return tail.isEmpty ? '0.' : '.'; // ".5" -> "0.5"
    }

    if (token == ')') {
      final open = '('.allMatches(_expression).length;
      final close = ')'.allMatches(_expression).length;
      if (open <= close || _expression.isEmpty) return null;
      final last = _expression[_expression.length - 1];
      if (last == '(' || _operators.contains(last)) return null;
      return token;
    }

    return token;
  }
}
