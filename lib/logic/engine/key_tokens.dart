/// Ánh xạ nhãn hiển thị trên phím -> chuỗi token mà [ExpressionEvaluator] hiểu.
///
/// Nằm ở lớp nền (không phải lớp giao diện) để màn hình Khoa học và màn hình
/// Cơ bản dùng chung một nguồn sự thật, và để test được mà không cần dựng UI.
const keyTokens = <String, String>{
  // Cơ bản
  '÷': '÷', '×': '×', '−': '−', '+': '+',
  '%': '%', '.': '.', '00': '00',

  // Khoa học
  '√': 'sqrt(',
  'x²': '^2',
  'xʸ': '^',
  'sin': 'sin(',
  'cos': 'cos(',
  'tan': 'tan(',
  'log': 'log(',
  'ln': 'ln(',
  'n!': '!',
  'π': 'π',
  '(': '(',
  ')': ')',
};

/// Nhãn phím -> token; nếu không có trong bảng thì dùng chính nhãn đó
/// (các phím số 0-9).
String tokenFor(String label) => keyTokens[label] ?? label;
