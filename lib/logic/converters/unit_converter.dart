enum UnitCategory { length, weight, temperature, data, time }

extension UnitCategoryLabel on UnitCategory {
  String get label => switch (this) {
    UnitCategory.length => 'Độ dài',
    UnitCategory.weight => 'Khối lượng',
    UnitCategory.temperature => 'Nhiệt độ',
    UnitCategory.data => 'Dữ liệu',
    UnitCategory.time => 'Thời gian',
  };
}

const unitFactors = <UnitCategory, Map<String, double>>{
  UnitCategory.length: {
    // gốc: mét
    'mm': 0.001, 'cm': 0.01, 'm': 1, 'km': 1000,
    'inch': 0.0254, 'ft': 0.3048, 'mile': 1609.344,
  },
  UnitCategory.weight: {
    // gốc: gram
    'mg': 0.001, 'g': 1, 'kg': 1000, 'ton': 1000000,
    'oz': 28.3495, 'lb': 453.592,
  },
  UnitCategory.data: {
    // gốc: byte
    'B': 1, 'KB': 1024, 'MB': 1048576,
    'GB': 1073741824, 'TB': 1099511627776,
  },
  UnitCategory.time: {
    // gốc: giây
    'ms': 0.001, 's': 1, 'min': 60, 'h': 3600,
    'day': 86400, 'week': 604800,
  },
};

const temperatureUnits = ['°C', '°F', 'K'];

class UnitConverter {
  UnitConverter._();

  static double convert({
    required UnitCategory category,
    required String from,
    required String to,
    required double value,
  }) {
    if (category == UnitCategory.temperature) {
      return _temperature(from, to, value);
    }
    final factors = unitFactors[category]!;
    final f = factors[from];
    final t = factors[to];
    if (f == null || t == null) {
      throw ArgumentError('Đơn vị không thuộc nhóm ${category.label}');
    }
    return value * f / t;
  }

  static double _temperature(String from, String to, double v) {
    final celsius = switch (from) {
      '°F' => (v - 32) * 5 / 9,
      'K' => v - 273.15,
      _ => v,
    };
    return switch (to) {
      '°F' => celsius * 9 / 5 + 32,
      'K' => celsius + 273.15,
      _ => celsius,
    };
  }

  static List<String> unitsOf(UnitCategory c) => c == UnitCategory.temperature
      ? List.of(temperatureUnits)
      : unitFactors[c]!.keys.toList();
}
