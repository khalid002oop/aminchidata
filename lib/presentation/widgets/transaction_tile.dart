import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel txn;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.txn, this.onTap});

  Color get _statusColor {
    if (txn.isSuccess) return AppColors.success;
    if (txn.isPending) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(Helpers.serviceIcon(txn.serviceType), style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(txn.serviceType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(txn.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(Helpers.formatShortDate(txn.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(Helpers.formatCurrency(txn.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(txn.status, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
