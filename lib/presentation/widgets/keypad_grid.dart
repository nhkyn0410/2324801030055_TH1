import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import 'calc_key_button.dart';

class KeypadGrid extends StatelessWidget {
  const KeypadGrid({
    super.key,
    required this.keys,
    required this.onKey,
    this.columns = 4,
    this.keyHeight = AppDimens.keyHeight,
    this.gap = AppDimens.keyGap,
  });

  final List<CalcKey> keys;
  final int columns;
  final double keyHeight;
  final double gap;
  final ValueChanged<CalcKey> onKey;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: keys.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: keyHeight,
      ),
      itemBuilder: (_, i) => CalcKeyButton(
        data: keys[i],
        height: keyHeight,
        onTap: () => onKey(keys[i]),
      ),
    );
  }
}
