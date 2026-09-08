import 'package:flutter_test/flutter_test.dart';
import 'package:th1_2324801030055/logic/engine/expression_evaluator.dart';

void main() {
  final e = ExpressionEvaluator();

  group('Thứ tự ưu tiên', () {
    test('nhân trước cộng', () => expect(e.evaluate('1250×8.5+450'), 11075));
    test('2+3×4 = 14', () => expect(e.evaluate('2+3×4'), 14));
    test('luỹ thừa kết hợp phải', () => expect(e.evaluate('2^3^2'), 512));
    test('-2^2 = -4 (quy ước toán học)', () => expect(e.evaluate('-2^2'), -4));
    test('(-2)^2 = 4', () => expect(e.evaluate('(-2)^2'), 4));
    test('số mũ âm', () => expect(e.evaluate('2^-3'), 0.125));
    test('-2×3 = -6', () => expect(e.evaluate('-2×3'), -6));
    test('-5! = -120', () => expect(e.evaluate('-5!'), -120));
    test('-√16 = -4', () => expect(e.evaluate('-√16'), -4));
  });

  group('Phần trăm là chia 100', () {
    test('50% = 0.5', () => expect(e.evaluate('50%'), 0.5));
    test('200+10% = 200.1',
        () => expect(e.evaluate('200+10%'), closeTo(200.1, 1e-9)));
    test('200×10% = 20', () => expect(e.evaluate('200×10%'), 20));
  });

  group('Bốn phép cơ bản', () {
    test('cộng', () => expect(e.evaluate('7+8'), 15));
    test('trừ', () => expect(e.evaluate('7−8'), -1));
    test('nhân', () => expect(e.evaluate('7×8'), 56));
    test('chia', () => expect(e.evaluate('8÷2'), 4));
    test('số thập phân', () => expect(e.evaluate('0.1+0.2'), closeTo(0.3, 1e-9)));
  });

  group('Khoa học', () {
    test('căn bậc hai', () => expect(e.evaluate('sqrt(16)'), 4));
    test('ký hiệu √', () => expect(e.evaluate('√16'), 4));
    test('luỹ thừa', () => expect(e.evaluate('2^10'), 1024));
    test('giai thừa', () => expect(e.evaluate('5!'), 120));
    test('log cơ số 10', () => expect(e.evaluate('log(100)'), 2));
    test('ln(1) = 0', () => expect(e.evaluate('ln(1)'), 0));
    test('sin 30° = 0.5', () => expect(e.evaluate('sin(30)'), closeTo(0.5, 1e-9)));
    test('cos 60° = 0.5', () => expect(e.evaluate('cos(60)'), closeTo(0.5, 1e-9)));
    test('tan 45° = 1', () => expect(e.evaluate('tan(45)'), closeTo(1, 1e-9)));
  });

  test('chế độ RAD', () {
    final rad = ExpressionEvaluator(degrees: false);
    expect(rad.evaluate('sin(0)'), 0);
    expect(rad.evaluate('cos(0)'), 1);
  });

  group('Nhân ngầm', () {
    test('2π', () => expect(e.evaluate('2π'), closeTo(6.283185307, 1e-8)));
    test('2(3+4)', () => expect(e.evaluate('2(3+4)'), 14));
    test('(1+2)(3+4)', () => expect(e.evaluate('(1+2)(3+4)'), 21));
  });

  group('Ký hiệu mũ (do double.toString sinh ra)', () {
    test('1e3 = 1000', () => expect(e.evaluate('1e3'), 1000));
    test('1e+21 KHÔNG bị đọc thành 1×e+21',
        () => expect(e.evaluate('1e+21'), 1e21));
    test('1.5e-3', () => expect(e.evaluate('1.5e-3'), closeTo(0.0015, 1e-12)));
  });

  group('Báo lỗi đúng', () {
    for (final bad in [
      '1÷0',
      '1.2.3',
      '(2+3',
      '2+3)',
      '5+',
      'sqrt(-4)',
      'log(0)',
      'abc(2)',
      '',
    ]) {
      test('"$bad" ném FormatException',
          () => expect(() => e.evaluate(bad), throwsFormatException));
    }
  });
}
