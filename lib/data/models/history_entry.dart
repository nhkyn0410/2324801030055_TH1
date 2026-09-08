/// Một dòng trong lịch sử tính toán.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.time,
  });

  /// Định danh ổn định — xoá theo id chứ không theo vị trí trong danh sách.
  final String id;

  final String expression;

  /// Số thô. KHÔNG lưu chuỗi đã format: "11,075.00" sẽ không parse ngược
  /// được khi đổi locale.
  final double result;

  final DateTime time;

  Map<String, dynamic> toJson() => {
        'id': id,
        'e': expression,
        'r': result,
        't': time.millisecondsSinceEpoch,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        expression: json['e'] as String,
        result: (json['r'] as num).toDouble(),
        time: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
      );
}
