import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool visible;
  final VoidCallback onToggle;
  final String? accountNumber;
  final String? bankName;
  final VoidCallback? onFund;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.visible,
    required this.onToggle,
    this.accountNumber,
    this.bankName,
    this.onFund,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              GestureDetector(
                onTap: onToggle,
                child: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            visible ? Helpers.formatCurrency(balance) : '₦ ****',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          if (accountNumber != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(bankName ?? '', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(accountNumber!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: accountNumber!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied!'), duration: Duration(seconds: 2)));
                    },
                    child: const Icon(Icons.copy, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onFund,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: const Text('+ Fund Wallet', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
