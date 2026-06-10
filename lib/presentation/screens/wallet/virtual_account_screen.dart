import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/app_button.dart';

class VirtualAccountScreen extends StatefulWidget {
  const VirtualAccountScreen({super.key});
  @override
  State<VirtualAccountScreen> createState() => _VirtualAccountScreenState();
}

class _VirtualAccountScreenState extends State<VirtualAccountScreen> {
  late final WalletController _wallet;
  @override
  void initState() { super.initState(); _wallet = Get.find<WalletController>(); _wallet.loadVirtualAccount(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Account')),
      backgroundColor: AppColors.background,
      body: const VirtualAccountBody(),
    );
  }
}

class VirtualAccountBody extends StatelessWidget {
  const VirtualAccountBody({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.find<WalletController>();
    return Obx(() {
      if (wallet.isLoading.value && wallet.virtualAccount.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final VirtualAccount? va = wallet.virtualAccount.value;
      if (va == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No virtual account yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Generate a dedicated bank account to fund your wallet via direct transfer.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Obx(() => AppButton(label: 'Generate Account', isLoading: wallet.isLoading.value, onPressed: wallet.generateVirtualAccount)),
            ]),
          ),
        );
      }
      return ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.account_balance, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Virtual Account', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
            const SizedBox(height: 20),
            Text(va.bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(va.accountNumber, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2))),
              IconButton(icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () {
                Clipboard.setData(ClipboardData(text: va.accountNumber));
                Get.snackbar('Copied', 'Account number copied', backgroundColor: Colors.black87, colorText: Colors.white, duration: const Duration(seconds: 2));
              }),
            ]),
            const SizedBox(height: 4),
            Text(va.accountName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18), SizedBox(width: 6), Text('Important', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.orange))]),
          SizedBox(height: 8),
          Text('• Transfer from your bank account to fund wallet\n• Credits are applied within 5 minutes\n• Minimum transfer: ₦100\n• Keep your account number private', style: TextStyle(fontSize: 13, height: 1.6)),
        ])),
        const SizedBox(height: 16),
        OutlinedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Refresh'), onPressed: wallet.loadVirtualAccount),
      ]);
    });
  }
}
