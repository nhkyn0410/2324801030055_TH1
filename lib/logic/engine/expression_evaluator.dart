import 'dart:math' as math;

import 'math_ops.dart';

/// Tính giá trị một biểu thức trung tố bằng thuật toán Shunting-yard:
/// chuỗi -> danh sách token -> ký pháp hậu tố (RPN) -> kết quả.
///
/// Ném [FormatException] với thông báo tiếng Việt cho mọi đầu vào không hợp lệ.
class ExpressionEvaluator {
  ExpressionEvaluator({this.degrees = true});

  /// true = chế độ DEG (đơn vị góc hiển thị trên panel), false = RAD.
  final bool degrees;

  static const _functions = {'sin', 'cos', 'tan', 'log', 'ln', 'sqrt'};

  /// Chỉ có π. KHÔNG thêm 'e' (Euler): nó đụng với ký hiệu mũ của
  /// double.toString() — "1e+21" sẽ bị đọc thành 1 × e + 21.
  static const _constants = <String, double>{'π': math.pi};

  /// Toán tử nhị phân: ký hiệu -> (độ ưu tiên, có kết hợp phải không).
  static const _binary = <String, (int, bool)>{
    '+': (2, false),
    '-': (2, false),
    '*': (3, false),
    '/': (3, false),
    '^': (5, true),
  };

  /// Dấu trừ một ngôi nằm GIỮA (* /) và (^) để `-2^2` = -(2^2) = -4,
  /// đúng quy ước toán học, trong khi `-2*3` vẫn = -6.
  static const _unaryPrec = 4;
  static const _funcPrec = 6;

  static final _digit = RegExp(r'[0-9]');
  static final _digitOrDot = RegExp(r'[0-9.]');
  static final _letter = RegExp(r'[a-z]');

  double evaluate(String input) => _evalRpn(_toRpn(_tokenize(input)));

  // ---------------------------------------------------------------- tokenize

  List<String> _tokenize(String source) {
    // Chuẩn hoá ký hiệu hiển thị -> ký hiệu nội bộ.
    final s = source
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('√', 'sqrt')
        .replaceAll(',', '')
        .replaceAll(' ', '');

    final out = <String>[];

    /// Chèn dấu '*' ngầm để `2π`, `2(3+4)`, `(1+2)(3+4)` chạy đúng thay vì
    /// bị dính thành một số hoặc báo lỗi.
    void implicitMul() {
      if (out.isEmpty) return;
      final last = out.last;
      if (double.tryParse(last) != null ||
          last == ')' ||
          last == '!' ||
          last == '%') {
        out.add('*');
      }
    }

    var i = 0;
    while (i < s.length) {
      final c = s[i];

      if (_constants.containsKey(c)) {
        implicitMul();
        out.add('${_constants[c]}');
        i++;
        continue;
      }

      if (_digitOrDot.hasMatch(c)) {
        implicitMul();
        final buf = StringBuffer();
        while (i < s.length && _digitOrDot.hasMatch(s[i])) {
          buf.write(s[i++]);
        }
        i = _readExponent(s, i, buf);
        final tok = buf.toString();
        if (double.tryParse(tok) == null) {
          // Chặn "1.2.3" ngay tại đây thay vì để lỗi trồi lên ở bước sau.
          throw FormatException('Số không hợp lệ: $tok');
        }
        out.add(tok);
        continue;
      }

      if (_letter.hasMatch(c)) {
        implicitMul();
        final buf = StringBuffer();
        while (i < s.length && _letter.hasMatch(s[i])) {
          buf.write(s[i++]);
        }
        final name = buf.toString();
        if (!_functions.contains(name)) {
          throw FormatException('Hàm không hợp lệ: $name');
        }
        out.add(name);
        continue;
      }

      if (c == '(') implicitMul();

      // Dấu '-' đứng đầu, sau '(' hoặc sau một toán tử => trừ một ngôi.
      if (c == '-' &&
          (out.isEmpty || out.last == '(' || _binary.containsKey(out.last))) {
        out.add('u-');
        i++;
        continue;
      }

      out.add(c);
      i++;
    }
    return out;
  }

  /// Đọc phần mũ dạng `e21`, `e+21`, `E-7` nối ngay sau phần định trị.
  /// Trả về vị trí mới; nếu không phải ký hiệu mũ thì trả về [i] không đổi.
  int _readExponent(String s, int i, StringBuffer buf) {
    if (i >= s.length || (s[i] != 'e' && s[i] != 'E')) return i;

    var j = i;
    final exp = StringBuffer(s[j++]);
    if (j < s.length && (s[j] == '+' || s[j] == '-')) {
      exp.write(s[j++]);
    }
    if (j >= s.length || !_digit.hasMatch(s[j])) {
      return i; // "2e" hay "2e+" -> không phải mũ, trả chữ 'e' lại cho vòng sau
    }
    while (j < s.length && _digit.hasMatch(s[j])) {
      exp.write(s[j++]);
    }
    buf.write(exp);
    return j;
  }

  // ------------------------------------------------------- trung tố -> RPN

  List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];

    for (final t in tokens) {
      if (double.tryParse(t) != null) {
        output.add(t);
      } else if (_functions.contains(t) || t == 'u-') {
        stack.add(t);
      } else if (t == '!' || t == '%') {
        // Toán tử một ngôi hậu tố: toán hạng đã nằm sẵn trong output.
        output.add(t);
      } else if (_binary.containsKey(t)) {
        final (prec, rightAssoc) = _binary[t]!;
        while (stack.isNotEmpty && stack.last != '(') {
          final topPrec = _precedenceOf(stack.last);
          if (topPrec > prec || (topPrec == prec && !rightAssoc)) {
            output.add(stack.removeLast());
          } else {
            break;
          }
        }
        stack.add(t);
      } else if (t == '(') {
        stack.add(t);
      } else if (t == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) throw const FormatException('Thiếu dấu (');
        stack.removeLast();
        if (stack.isNotEmpty && _functions.contains(stack.last)) {
          output.add(stack.removeLast());
        }
      } else {
        throw FormatException('Ký tự lạ: $t');
      }
    }

    while (stack.isNotEmpty) {
      final op = stack.removeLast();
      if (op == '(') throw const FormatException('Thiếu dấu )');
      output.add(op);
    }
    return output;
  }

  int _precedenceOf(String token) {
    if (_functions.contains(token)) return _funcPrec;
    if (token == 'u-') return _unaryPrec;
    return _binary[token]!.$1;
  }

  // ------------------------------------------------------------- tính RPN

  double _evalRpn(List<String> rpn) {
    final st = <double>[];

    double pop() {
      if (st.isEmpty) throw const FormatException('Biểu thức không hợp lệ');
      return st.removeLast();
    }

    for (final t in rpn) {
      final n = double.tryParse(t);
      if (n != null) {
        st.add(n);
        continue;
      }
      switch (t) {
        case '+':
          final b = pop();
          st.add(pop() + b);
        case '-':
          final b = pop();
          st.add(pop() - b);
        case '*':
          final b = pop();
          st.add(pop() * b);
        case '/':
          final b = pop();
          if (b == 0) throw const FormatException('Không thể chia cho 0');
          st.add(pop() / b);
        case '^':
          final b = pop();
          st.add(MathOps.pow(pop(), b));
        case 'u-':
          st.add(-pop());
        case '%':
          st.add(pop() / 100);
        case '!':
          st.add(MathOps.factorial(pop()));
        case 'sqrt':
          st.add(MathOps.sqrt(pop()));
        case 'sin':
          st.add(MathOps.sin(pop(), degrees));
        case 'cos':
          st.add(MathOps.cos(pop(), degrees));
        case 'tan':
          st.add(MathOps.tan(pop(), degrees));
        case 'log':
          st.add(MathOps.log10(pop()));
        case 'ln':
          st.add(MathOps.ln(pop()));
        default:
          throw FormatException('Toán tử lạ: $t');
      }
    }

    if (st.length != 1) throw const FormatException('Biểu thức không hợp lệ');
    final result = st.single;
    if (result.isNaN) throw const FormatException('Kết quả không xác định');
    if (result.isInfinite) throw const FormatException('Kết quả vượt giới hạn');
    return result;
  }
}
