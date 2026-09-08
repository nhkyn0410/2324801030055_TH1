import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'logic/providers/calculator_provider.dart';
import 'logic/providers/converter_provider.dart';
import 'logic/providers/history_provider.dart';
import 'logic/providers/memory_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => ConverterProvider()),
        ChangeNotifierProvider<MemoryProvider>(
          create: (_) {
            final provider = MemoryProvider();
            // Không await: load() đã tự bắt lỗi và gọi notifyListeners().
            unawaited(provider.load());
            return provider;
          },
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) {
            final provider = HistoryProvider();
            unawaited(provider.load());
            return provider;
          },
        ),
      ],
      child: const NovaCalcApp(),
    ),
  );
}
