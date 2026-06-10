import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../controllers/transaction_controller.dart';

class ReceiptScreen extends StatefulWidget {
  final String tid;
  const ReceiptScreen({super.key, required this.tid});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late final TransactionController _tx;

  @override
  void initState() { super.initState(); _tx = Get.find<TransactionController>(); _tx.loadReceipt(widget.tid); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (_tx.isLoading.value) return const Center(child: CircularProgressIndicator());
        final txn = _tx.receipt.value;
        if (txn == null) return const Center(child: Text('Receipt not found'));

        final Color statusColor = txn.isSuccess ? AppColors.success : txn.isPending ? AppColors.warning : AppColors.error;
        final IconData statusIcon = txn.isSuccess ? Icons.check_circle : txn.isPending ? Icons.access_time : Icons.cancel;

        return ListView(padding: const EdgeInsets.all(16), children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              CircleAvatar(radius: 32, backgroundColor: statusColor.withOpacity(0.15), child: Icon(statusIcon, color: statusColor, size: 36)),
              const SizedBox(height: 12),
              Text(txn.status.capitalizeFirst!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
              const SizedBox(height: 4),
              Text(Helpers.formatCurrency(txn.amount), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(txn.description, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 16),
          // Details card
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _row('Transaction ID', txn.id, copyable: true),
              _row('Service', txn.serviceType.replaceAll('_', ' ').capitalizeFirst!),
              _row('Date', Helpers.formatDate(txn.createdAt)),
              if (txn.phone != null) _row('Phone', txn.phone!),
              if (txn.network != null) _row('Network', txn.network!),
              if (txn.planName != null) _row('Plan', txn.planName!),
              if (txn.smartCardNumber != null) _row('Smart Card', txn.smartCardNumber!),
              if (txn.meterNumber != null) _row('Meter No.', txn.meterNumber!),
              if (txn.token != null) _row('Token', txn.token!, copyable: true),
              if (txn.pins != null && txn.pins!.isNotEmpty) ...[
                const Divider(height: 24),
                const Align(alignment: Alignment.centerLeft, child: Text('Generated PINs', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),
                ...txn.pins!.map((pin) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(child: Text(pin, style: const TextStyle(fontFamily: 'monospace', fontSize: 15))),
                    IconButton(icon: const Icon(Icons.copy, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
                      Clipboard.setData(ClipboardData(text: pin));
                      Get.snackbar('Copied', 'PIN copied', backgroundColor: Colors.black87, colorText: Colors.white, duration: const Duration(seconds: 2));
                    }),
                  ]),
                )),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(icon: const Icon(Icons.home_outlined), label: const Text('Back to Home'), onPressed: () => Get.offAllNamed('/home')),
        ]);
      }),
    );
  }

  Widget _row(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(flex: 3, child: Row(children: [
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
          if (copyable) GestureDetector(
            onTap: () { Clipboard.setData(ClipboardData(text: value)); Get.snackbar('Copied', '$label copied', backgroundColor: Colors.black87, colorText: Colors.white, duration: const Duration(seconds: 2)); },
            child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.copy, size: 14, color: AppColors.primary)),
          ),
        ])),
      ]),
    );
  }
}
