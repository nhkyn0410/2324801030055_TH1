import 'package:flutter_test/flutter_test.dart';
import 'package:th1_2324801030055/logic/providers/calculator_provider.dart';

void main() {
  late CalculatorProvider calc;

  setUp(() => calc = CalculatorProvider());

  void type(String keys) {
    for (final k in keys.split('')) {
      calc.input(k);
    }
  }

  group('Chặn đầu vào không hợp lệ', () {
    test('không cho hai dấu chấm trong một số', () {
      type('1.2');
      calc.input('.');
      expect(calc.expression, '1.2');
    });

    test('dấu chấm mở đầu thành 0.', () {
      calc.input('.');
      expect(calc.expression, '0.');
    });

    test('toán tử liên tiếp thì thay thế', () {
      type('5+');
      calc.input('×');
      expect(calc.expression, '5×');
    });

    test('cho phép dấu âm sau ^ × ÷', () {
      type('2^');
      calc.input('-');
      expect(calc.expression, '2^-');
    });

    test('không mở đầu bằng toán tử (trừ dấu âm)', () {
      calc.input('×');
      expect(calc.expression, isEmpty);
      calc.input('-');
      expect(calc.expression, '-');
    });

    test('không đóng ngoặc khi chưa mở', () {
      type('12');
      calc.input(')');
      expect(calc.expression, '12');
    });
  });

  group('Đổi dấu số đang nhập', () {
    test('2+3 -> 2+-3 = -1', () {
      type('2+3');
      calc.toggleSign();
      expect(calc.expression, '2+-3');
      expect(calc.lastValue, -1);
    });

    test('bấm lại thì trở về như cũ', () {
      type('2+3');
      calc.toggleSign();
      calc.toggleSign();
      expect(calc.expression, '2+3');
      expect(calc.lastValue, 5);
    });

    test('số đơn lẻ', () {
      type('5');
      calc.toggleSign();
      expect(calc.expression, '-5');
    });
  });

  group('Kết quả', () {
    test('equals trả về số thô, không phải chuỗi đã format', () {
      type('1250×8.5+450');
      final r = calc.equals();
      expect(r, isNotNull);
      expect(r!.value, 11075);
      expect(r.expression, '1250×8.5+450');
      expect(calc.result, '11,075'); // chuỗi chỉ để hiển thị
    });

    test('gõ số sau dấu = thì bắt đầu biểu thức mới', () {
      type('2+3');
      calc.equals();
      calc.input('7');
      expect(calc.expression, '7');
    });

    test('gõ toán tử sau dấu = thì tính tiếp trên kết quả', () {
      type('2+3');
      calc.equals();
      calc.input('×');
      expect(calc.expression, '5.0×');
      calc.input('2');
      expect(calc.lastValue, 10);
    });

    test('chia cho 0 báo lỗi và không ghi lịch sử', () {
      type('1÷0');
      expect(calc.equals(), isNull);
      expect(calc.error, 'Không thể chia cho 0');
      expect(calc.result, 'Lỗi');
    });

    test('xem trước không báo lỗi khi biểu thức còn dở', () {
      type('5+');
      expect(calc.error, isNull);
      expect(calc.result, '5');
    });

    test('AC đưa về trạng thái ban đầu', () {
      type('99×9');
      calc.clearAll();
      expect(calc.expression, isEmpty);
      expect(calc.result, '0');
      expect(calc.lastValue, 0);
      expect(calc.error, isNull);
    });
  });

  test('đổi DEG/RAD tính lại ngay', () {
    calc.loadExpression('sin(90)');
    expect(calc.lastValue, closeTo(1, 1e-9));
    calc.toggleAngleUnit();
    expect(calc.angleUnit, 'RAD');
    expect(calc.lastValue, closeTo(0.8939966636, 1e-8));
  });
}
