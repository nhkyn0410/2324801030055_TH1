import 'dart:math' as math;

class MathOps {
  MathOps._();

  static double sqrt(double x) {
    if (x < 0) throw const FormatException('Căn của số âm');
    return math.sqrt(x);
  }

  static double pow(double a, double b) => math.pow(a, b).toDouble();
  static double sin(double x, bool deg) => math.sin(deg ? _rad(x) : x);
  static double cos(double x, bool deg) => math.cos(deg ? _rad(x) : x);
  static double tan(double x, bool deg) => math.tan(deg ? _rad(x) : x);

  static double log10(double x) {
    if (x <= 0) throw const FormatException('log của số ≤ 0');
    return math.log(x) / math.ln10;
  }

  static double ln(double x) {
    if (x <= 0) throw const FormatException('ln của số ≤ 0');
    return math.log(x);
  }

  static double factorial(double x) {
    if (x < 0 || x != x.roundToDouble()) {
      throw const FormatException('Giai thừa cần số nguyên ≥ 0');
    }
    if (x > 170) throw const FormatException('Tràn số');
    var r = 1.0;
    for (var i = 2; i <= x.toInt(); i++) {
      r *= i;
    }
    return r;
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
