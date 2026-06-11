import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/transaction_controller.dart';

class ReceiptScreen extends StatefulWidget {
  final String tid;
  const ReceiptScreen({super.key, required this.tid});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late final TransactionController _tx;
  Timer? _pollTimer;
  int _pollCount = 0;
  static const _maxPolls = 12; // poll for up to 60 seconds

  @override
  void initState() {
    super.initState();
    _tx = Get.find<TransactionController>();
    _loadReceipt();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReceipt() async {
    await _tx.loadReceipt(widget.tid);
    _startPollingIfPending();
  }

  void _startPollingIfPending() {
    final txn = _tx.receipt.value;
    if (txn == null || !txn.isPending) return;
    _pollTimer?.cancel();
    _pollCount = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) { _pollTimer?.cancel(); return; }
      _pollCount++;
      await _tx.refreshReceipt(widget.tid);
      final current = _tx.receipt.value;
      if (current != null && !current.isPending) {
        _pollTimer?.cancel();
        // Refresh home balance now that transaction resolved
        try { Get.find<HomeController>().refreshBalance(); } catch (_) {}
        if (!mounted) return;
        setState(() {}); // re-render the resolved status icon
      }
      if (_pollCount >= _maxPolls) _pollTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (_tx.isLoading.value) return const Center(child: CircularProgressIndicator());
        final txn = _tx.receipt.value;
        if (txn == null) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Receipt not found', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextButton(onPressed: () => _tx.loadReceipt(widget.tid), child: const Text('Try again')),
            ]),
          );
        }

        final Color statusColor = txn.isSuccess
            ? AppColors.success
            : txn.isPending
                ? AppColors.warning
                : AppColors.error;
        final IconData statusIcon = txn.isSuccess
            ? Icons.check_circle
            : txn.isPending
                ? Icons.access_time
                : Icons.cancel;

        final bool stillPolling = txn.isPending && _pollCount < _maxPolls;

        return ListView(padding: const EdgeInsets.all(16), children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(statusIcon, color: statusColor, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                txn.status.capitalizeFirst!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
              ),
              const SizedBox(height: 4),
              Text(Helpers.formatCurrency(txn.amount), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(txn.description, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
              if (stillPolling) ...[
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Confirming with provider...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ],
              if (txn.isPending && _pollCount >= _maxPolls) ...[
                const SizedBox(height: 12),
                const Text(
                  'Taking longer than expected.\nCheck transaction history for updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          // Details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _row('Transaction ID', txn.id, copyable: true),
              _row('Service', txn.serviceType.replaceAll('_', ' ').capitalizeFirst!),
              _row('Date', Helpers.formatDate(txn.createdAt)),
              if (txn.phone != null) _row('Phone', txn.phone!),
              if (txn.network != null) _row('Network', txn.network!),
              if (txn.planName != null) _row('Plan', txn.planName!),
              if (txn.smartCardNumber != null) _row('Smart Card', txn.smartCardNumber!),
              if (txn.cable != null) _row('Cable', txn.cable!),
              if (txn.meterNumber != null) _row('Meter No.', txn.meterNumber!),
              if (txn.disco != null) _row('DISCO', txn.disco!),
              if (txn.meterType != null) _row('Meter Type', txn.meterType!),
              if (txn.exam != null) _row('Exam', txn.exam!),
              if (txn.quantity != null) _row('Quantity', txn.quantity!.toString()),
              if (txn.token != null) _row('Token', txn.token!, copyable: true),
              if (txn.pins != null && txn.pins!.isNotEmpty) ...[
                const Divider(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Generated PINs', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ...txn.pins!.map((pin) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(child: Text(pin, style: const TextStyle(fontFamily: 'monospace', fontSize: 15))),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: pin));
                        Get.snackbar('Copied', 'PIN copied',
                            backgroundColor: Colors.black87, colorText: Colors.white,
                            duration: const Duration(seconds: 2));
                      },
                    ),
                  ]),
                )),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.home_outlined),
            label: const Text('Back to Home'),
            onPressed: () => Get.offAllNamed('/home'),
          ),
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
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar('Copied', '$label copied',
                  backgroundColor: Colors.black87, colorText: Colors.white,
                  duration: const Duration(seconds: 2));
            },
            child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.copy, size: 14, color: AppColors.primary)),
          ),
        ])),
      ]),
    );
  }
}
