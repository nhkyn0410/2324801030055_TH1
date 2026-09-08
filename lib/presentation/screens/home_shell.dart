import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/nova_bottom_nav.dart';
import 'calculator_screen.dart';
import 'converter_screen.dart';
import 'history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _fade = Duration(milliseconds: 180);

  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const CalculatorScreen(),
      const CalculatorScreen(scientific: true),
      HistoryScreen(onRecalculate: () => _goTo(0)),
      const ConverterScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < screens.length; i++)
              AnimatedOpacity(
                opacity: i == _index ? 1 : 0,
                duration: _fade,
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: i != _index,
                  child: TickerMode(enabled: i == _index, child: screens[i]),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NovaBottomNav(index: _index, onChanged: _goTo),
    );
  }
}
