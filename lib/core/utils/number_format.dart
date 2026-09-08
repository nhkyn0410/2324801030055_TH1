import 'package:intl/intl.dart';

/// Định dạng số để hiển thị. Chỉ dùng ở lớp giao diện — mọi tính toán,
/// lưu trữ và truyền qua lại giữa các provider đều dùng [double] thô.
class Num {
  Num._();

  /// Locale cố định 'en_US': dấu phẩy ngăn nghìn, dấu chấm thập phân —
  /// khớp với ký hiệu mà [ExpressionEvaluator] hiểu được.
  static final _plain = NumberFormat('#,##0.############', 'en_US');
  static final _sci = NumberFormat('0.##########E0', 'en_US');

  /// Ngoài dải này thì dạng #,##0 mất giá trị (số quá nhỏ thành "0")
  /// hoặc dài vô nghĩa (số quá lớn), nên rơi về ký hiệu mũ.
  static const _minPlain = 1e-9;
  static const _maxPlain = 1e15;

  static String format(double v) {
    if (v.isNaN) return 'Lỗi';
    if (v.isInfinite) return v.isNegative ? '-∞' : '∞';
    if (v == 0) return '0'; // gộp luôn -0.0

    final a = v.abs();
    if (a < _minPlain || a >= _maxPlain) return _sci.format(v);

    // Cắt về 12 chữ số thập phân để triệt nhiễu dấu phẩy động
    // (0.1 + 0.2 -> 0.30000000000000004 -> 0.3).
    return _plain.format(double.parse(v.toStringAsFixed(12)));
  }
}
