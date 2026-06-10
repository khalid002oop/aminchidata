import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pin_input.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});
  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _phoneCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _pin = '';
  String _network = 'MTN';

  final _networks = ['MTN', 'GLO', 'AIRTEL', '9MOBILE'];

  @override
  void dispose() { _phoneCtrl.dispose(); _amountCtrl.dispose(); super.dispose(); }

  void _buy() {
    if (!_formKey.currentState!.validate()) return;
    if (_pin.length < 4) { Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
    Get.find<ServiceController>().purchase({
      'service_type': 'airtime',
      'network': _network,
      'phone': _phoneCtrl.text.trim(),
      'amount': double.tryParse(_amountCtrl.text) ?? 0,
      'transaction_pin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<ServiceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Airtime')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Network', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _networks.map((n) => GestureDetector(
                  onTap: () => setState(() => _network = n),
                  child: Container(width: 70, height: 56,
                    decoration: BoxDecoration(
                      color: _network == n ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(n, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _network == n ? Colors.white : Colors.grey.shade700))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              AppTextField(label: 'Phone Number', hint: '08012345678', controller: _phoneCtrl,
                  keyboardType: TextInputType.phone, maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.phone_outlined), validator: Validators.phone),
              const SizedBox(height: 16),
              AppTextField(label: 'Amount (₦)', hint: '200', controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.money),
                  validator: (v) => Validators.amount(v, min: 50)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, children: [50, 100, 200, 500, 1000].map((a) => ActionChip(
                label: Text('₦$a'),
                onPressed: () => _amountCtrl.text = a.toString(),
              )).toList()),
              const SizedBox(height: 20),
              const Text('Transaction PIN', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              PinInput(onChanged: (v) => _pin = v, onCompleted: (v) => _pin = v),
              const SizedBox(height: 24),
              Obx(() => AppButton(label: 'Buy Airtime', isLoading: svc.isLoading.value, onPressed: _buy)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
