import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_format.dart';
import '../../data/models/history_entry.dart';
import '../../logic/providers/calculator_provider.dart';
import '../../logic/providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, this.onRecalculate});

  final VoidCallback? onRecalculate;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text('Chưa có phép tính nào', style: AppTextStyles.expression),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            12,
            AppDimens.screenPadding,
            4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${history.count} phép tính', style: AppTextStyles.label),
              TextButton.icon(
                onPressed: () => _confirmClear(context, history),
                icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                label: Text('Xoá tất cả', style: AppTextStyles.caption),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onDanger,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding,
              4,
              AppDimens.screenPadding,
              16,
            ),
            itemCount: history.count,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final entry = history.items[i];
              return _HistoryTile(
                entry: entry,
                // Xoá theo id, KHÔNG theo vị trí trong danh sách.
                onDelete: () => history.remove(entry.id),
                onTap: () {
                  context.read<CalculatorProvider>().loadExpression(
                    entry.expression,
                  );
                  onRecalculate?.call();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    HistoryProvider history,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('Xoá toàn bộ lịch sử?'),
        content: const Text('Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.onDanger),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok ?? false) await history.clearAll();
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppDimens.radiusKey),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.onDanger),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusKey),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusKey),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.expression,
                        style: AppTextStyles.expression,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Num.format(entry.result),
                        style: AppTextStyles.digit.copyWith(fontSize: 20),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('HH:mm\ndd/MM').format(entry.time),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
