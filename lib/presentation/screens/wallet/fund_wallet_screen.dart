import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'virtual_account_screen.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});
  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl    = TextEditingController();
  late final WalletController _wallet;
  int _tab = 0; // 0=Paystack, 1=Bank Transfer

  @override
  void initState() { super.initState(); _wallet = Get.find<WalletController>(); _wallet.loadVirtualAccount(); }

  @override
  void dispose() { _amountCtrl.dispose(); _refCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund Wallet')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 0), child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: _tab == 0 ? AppColors.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text('Card Payment', textAlign: TextAlign.center, style: TextStyle(color: _tab == 0 ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: () => setState(() => _tab = 1), child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: _tab == 1 ? AppColors.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text('Bank Transfer', textAlign: TextAlign.center, style: TextStyle(color: _tab == 1 ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ))),
            ]),
          ),
          Expanded(
            child: _tab == 0 ? _buildPaystack() : const VirtualAccountBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaystack() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Tap "Pay with Card" to open secure Paystack payment. After payment, enter your reference to verify.', style: TextStyle(fontSize: 13))),
            ])),
            const SizedBox(height: 20),
            AppTextField(label: 'Amount (₦)', hint: '5000', controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.money),
                validator: (v) => Validators.amount(v, min: 100)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [500, 1000, 2000, 5000, 10000].map((a) => ActionChip(label: Text('₦$a'), onPressed: () => _amountCtrl.text = a.toString())).toList()),
            const SizedBox(height: 24),
            Obx(() => AppButton(label: 'Pay with Card', isLoading: _wallet.isLoading.value, onPressed: () {
              if (_formKey.currentState!.validate()) _wallet.fundWallet(double.tryParse(_amountCtrl.text) ?? 0);
            })),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Already paid? Verify your payment', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            AppTextField(label: 'Payment Reference', hint: 'e.g. paystack_ref_xxx', controller: _refCtrl, prefixIcon: const Icon(Icons.receipt_outlined)),
            const SizedBox(height: 16),
            Obx(() => AppButton(label: 'Verify Payment', isLoading: _wallet.isLoading.value,
                color: AppColors.success,
                onPressed: () { if (_refCtrl.text.isNotEmpty) _wallet.verifyPayment(_refCtrl.text.trim()); })),
          ],
        ),
      ),
    );
  }
}
