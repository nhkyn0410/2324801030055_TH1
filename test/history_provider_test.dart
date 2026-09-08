import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:th1_2324801030055/logic/providers/history_provider.dart';
import 'package:th1_2324801030055/logic/providers/memory_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('HistoryProvider', () {
    test('thêm rồi đọc lại từ đĩa', () async {
      final a = HistoryProvider();
      await a.add('2+3', 5);
      await a.add('4×5', 20);

      final b = HistoryProvider();
      await b.load();
      expect(b.count, 2);
      expect(b.items.first.expression, '4×5'); // mới nhất lên đầu
      expect(b.items.first.result, 20);
    });

    test('kết quả giữ nguyên kiểu double, không qua chuỗi format', () async {
      final a = HistoryProvider();
      await a.add('10000×1.5', 15000);

      final b = HistoryProvider();
      await b.load();
      expect(b.items.first.result, 15000.0);
      expect(b.items.first.result, isA<double>());
    });

    test('xoá theo id, không theo vị trí', () async {
      final p = HistoryProvider();
      await p.add('1+1', 2);
      await p.add('2+2', 4);
      final id = p.items.last.id; // dòng "1+1"

      await p.remove(id);
      expect(p.count, 1);
      expect(p.items.single.expression, '2+2');
    });

    test('xoá tất cả', () async {
      final p = HistoryProvider();
      await p.add('1+1', 2);
      await p.clearAll();
      expect(p.isEmpty, isTrue);

      final b = HistoryProvider();
      await b.load();
      expect(b.isEmpty, isTrue);
    });

    test('dữ liệu hỏng thì trả về rỗng, không ném lỗi', () async {
      SharedPreferences.setMockInitialValues({
        'nova_history_v1': 'đây không phải JSON',
      });
      final p = HistoryProvider();
      await expectLater(p.load(), completes);
      expect(p.isEmpty, isTrue);
    });
  });

  group('MemoryProvider', () {
    test('M+ / M− / MC và ghi xuống đĩa', () async {
      final p = MemoryProvider();
      p.add(2500);
      expect(p.value, 2500);
      expect(p.hasValue, isTrue);
      expect(p.display, 'M: 2,500');

      p.subtract(500);
      expect(p.recall(), 2000);

      // chờ ghi nền hoàn tất rồi nạp lại
      await p.saved;
      final b = MemoryProvider();
      await b.load();
      expect(b.value, 2000);

      p.clear();
      expect(p.value, 0);
      expect(p.hasValue, isFalse);
    });
  });
}
