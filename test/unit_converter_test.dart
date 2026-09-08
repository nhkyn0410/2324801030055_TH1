import 'package:flutter_test/flutter_test.dart';
import 'package:th1_2324801030055/logic/converters/unit_converter.dart';
import 'package:th1_2324801030055/logic/providers/converter_provider.dart';

void main() {
  double conv(UnitCategory c, String from, String to, double v) =>
      UnitConverter.convert(category: c, from: from, to: to, value: v);

  group('Độ dài', () {
    test('1 km = 1000 m', () => expect(conv(UnitCategory.length, 'km', 'm', 1), 1000));
    test('1 inch = 2.54 cm',
        () => expect(conv(UnitCategory.length, 'inch', 'cm', 1), closeTo(2.54, 1e-9)));
  });

  group('Khối lượng', () {
    test('1 kg = 1000 g', () => expect(conv(UnitCategory.weight, 'kg', 'g', 1), 1000));
    test('1 lb ≈ 453.592 g',
        () => expect(conv(UnitCategory.weight, 'lb', 'g', 1), closeTo(453.592, 1e-6)));
  });

  group('Nhiệt độ (biến đổi affine, không phải tỉ lệ)', () {
    test('0°C = 32°F',
        () => expect(conv(UnitCategory.temperature, '°C', '°F', 0), 32));
    test('100°C = 212°F',
        () => expect(conv(UnitCategory.temperature, '°C', '°F', 100), 212));
    test('0°C = 273.15K',
        () => expect(conv(UnitCategory.temperature, '°C', 'K', 0), closeTo(273.15, 1e-9)));
    test('-40°C = -40°F',
        () => expect(conv(UnitCategory.temperature, '°C', '°F', -40), -40));
  });

  group('Dữ liệu', () {
    test('1 GB = 1024 MB',
        () => expect(conv(UnitCategory.data, 'GB', 'MB', 1), 1024));
    test('1 MB = 1048576 B',
        () => expect(conv(UnitCategory.data, 'MB', 'B', 1), 1048576));
  });

  group('Thời gian', () {
    test('1 h = 3600 s', () => expect(conv(UnitCategory.time, 'h', 's', 1), 3600));
    test('1 day = 24 h', () => expect(conv(UnitCategory.time, 'day', 'h', 1), 24));
  });

  group('ConverterProvider', () {
    test('đổi nhóm thì reset đơn vị về hợp lệ', () {
      final p = ConverterProvider();
      expect(p.units.contains(p.from), isTrue);
      p.setCategory(UnitCategory.temperature);
      expect(p.units, temperatureUnits);
      expect(p.units.contains(p.from), isTrue);
      expect(p.units.contains(p.to), isTrue);
    });

    test('nhập số rồi quy đổi', () {
      final p = ConverterProvider()
        ..setCategory(UnitCategory.length)
        ..setFrom('km')
        ..setTo('m')
        ..setInput('2.5');
      expect(p.result, 2500);
    });

    test('đầu vào rác thì báo lỗi và result null', () {
      final p = ConverterProvider()..setInput('abc');
      expect(p.error, isNotNull);
      expect(p.result, isNull);
    });

    test('đảo đơn vị', () {
      final p = ConverterProvider()
        ..setFrom('km')
        ..setTo('m')
        ..setInput('1');
      p.swap();
      expect(p.from, 'm');
      expect(p.to, 'km');
      expect(p.result, closeTo(0.001, 1e-12));
    });
  });
}
