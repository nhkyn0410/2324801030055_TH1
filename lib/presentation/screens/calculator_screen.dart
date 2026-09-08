import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_dimens.dart';
import '../../logic/engine/key_tokens.dart';
import '../../logic/providers/calculator_provider.dart';
import '../../logic/providers/history_provider.dart';
import '../../logic/providers/memory_provider.dart';
import '../widgets/calc_key_button.dart';
import '../widgets/display_panel.dart';
import '../widgets/keypad_grid.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key, this.scientific = false});

  final bool scientific;

  static const _sciKeyHeight = 44.0;
  static const _sciGap = 6.0;
  static const _memoryBarHeight = 38.0;
  static const _blockGap = 12.0;

  static const mainKeys = <CalcKey>[
    CalcKey('AC', style: KeyStyle.danger, subLabel: 'XÓA'),
    CalcKey('±', style: KeyStyle.function),
    CalcKey('%', style: KeyStyle.function),
    CalcKey('÷', style: KeyStyle.operator),
    CalcKey('7'),
    CalcKey('8'),
    CalcKey('9'),
    CalcKey('×', style: KeyStyle.operator),
    CalcKey('4'),
    CalcKey('5'),
    CalcKey('6'),
    CalcKey('−', style: KeyStyle.operator),
    CalcKey('1'),
    CalcKey('2'),
    CalcKey('3'),
    CalcKey('+', style: KeyStyle.operator),
    CalcKey('0'),
    CalcKey('.'),
    CalcKey('⌫', style: KeyStyle.function),
    CalcKey('=', style: KeyStyle.equals),
  ];

  static final sciKeys = <CalcKey>[
    for (final label in ['sin', 'cos', 'tan', 'log', 'ln', 'π'])
      CalcKey(label, style: KeyStyle.science, token: tokenFor(label)),
    for (final label in ['√', 'x²', 'xʸ', 'n!', '(', ')'])
      CalcKey(label, style: KeyStyle.science, token: tokenFor(label)),
  ];

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final memory = context.watch<MemoryProvider>();
    final history = context.watch<HistoryProvider>();

    void handle(CalcKey key) {
      switch (key.label) {
        case 'AC':
          calc.clearAll();
        case '⌫':
          calc.backspace();
        case '±':
          calc.toggleSign();
        case '=':
          final entry = calc.equals();
          if (entry != null) {
            history.add(entry.expression, entry.value);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(calc.error ?? 'Biểu thức không hợp lệ')),
            );
          }
        default:
          calc.input(key.value);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        8,
        AppDimens.screenPadding,
        16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const mainPadHeight =
              AppDimens.keyHeight * 5 + AppDimens.keyGap * 4; // 320
          const sciBlockHeight = _sciKeyHeight * 2 + _sciGap + _blockGap; // 106
          const memoryBlockHeight = _blockGap + _memoryBarHeight; // 50
          const used =
              AppDimens.panelMinHeight +
              memoryBlockHeight +
              sciBlockHeight +
              mainPadHeight;

          final free = (constraints.maxHeight - used).clamp(
            0.0,
            double.infinity,
          );

          final gap = free + (scientific ? 0.0 : sciBlockHeight);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  // ----- Ghim đỉnh: giống hệt ở cả hai tab -----
                  DisplayPanel(
                    expression: calc.expression,
                    result: calc.error ?? calc.result,
                    isError: calc.error != null,
                    memoryLabel: memory.display,
                    hasMemory: memory.hasValue,
                    angleUnit: calc.angleUnit,
                    onToggleAngle: calc.toggleAngleUnit,
                    note: memory.hasValue ? 'Tổng tích lũy' : null,
                  ),
                  const SizedBox(height: _blockGap),

                  // MemoryBar(
                  //   hasMemory: memory.hasValue,
                  //   onMc: memory.clear,
                  //   onMr: () => calc.loadExpression(memory.recall().toString()),
                  //   onMPlus: () => memory.add(calc.lastValue),
                  //   onMMinus: () => memory.subtract(calc.lastValue),
                  // ),
                  SizedBox(height: gap),

                  if (scientific) ...[
                    KeypadGrid(
                      keys: sciKeys,
                      columns: 6,
                      keyHeight: _sciKeyHeight,
                      gap: _sciGap,
                      onKey: handle,
                    ),
                    const SizedBox(height: _blockGap),
                  ],

                  KeypadGrid(keys: mainKeys, onKey: handle),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
