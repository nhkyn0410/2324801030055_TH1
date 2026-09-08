import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_format.dart';
import '../../logic/converters/unit_converter.dart';
import '../../logic/providers/converter_provider.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ConverterProvider>().rawInput,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConverterProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        12,
        AppDimens.screenPadding,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final c in p.categories)
                  ChoiceChip(
                    label: Text(c.label, style: AppTextStyles.caption),
                    selected: c == p.category,
                    showCheckmark: false,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.surfaceAlt,
                    side: BorderSide(
                      color: c == p.category
                          ? AppColors.accent
                          : Colors.transparent,
                    ),
                    onSelected: (_) => p.setCategory(c),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Field(
            label: 'Từ',
            unit: p.from,
            units: p.units,
            onUnitChanged: p.setFrom,
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
              ],
              style: AppTextStyles.digit.copyWith(fontSize: 22),
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: p.setInput,
            ),
          ),
          Align(
            child: IconButton(
              onPressed: p.swap,
              icon: const Icon(Icons.swap_vert_rounded),
              color: AppColors.accent,
              tooltip: 'Đảo đơn vị',
            ),
          ),
          _Field(
            label: 'Sang',
            unit: p.to,
            units: p.units,
            onUnitChanged: p.setTo,
            child: Text(
              p.result == null ? '—' : Num.format(p.result!),
              style: AppTextStyles.digit.copyWith(fontSize: 22),
              maxLines: 1,
            ),
          ),

          if (p.error != null) ...[
            const SizedBox(height: 12),
            Text(
              p.error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.onDanger),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
    required this.child,
  });

  final String label;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusKey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: child),
              const SizedBox(width: 12),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: unit,
                  dropdownColor: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(
                    AppDimens.radiusMemoryKey,
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                  items: [
                    for (final u in units)
                      DropdownMenuItem(value: u, child: Text(u)),
                  ],
                  onChanged: (v) => v == null ? null : onUnitChanged(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
