import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/transaction_pin_field.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});
  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _meterCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _pin = '';
  String _meterType = 'PREPAID';
  bool _validated = false;
  late final ServiceController _svc;

  @override
  void initState() { super.initState(); _svc = Get.find<ServiceController>(); _svc.loadDiscos(); }

  @override
  void dispose() { _meterCtrl.dispose(); _amountCtrl.dispose(); super.dispose(); }

  Future<void> _validate() async {
    if (_svc.selectedDisco.value == null) { Get.snackbar('Error', 'Select a DISCO', snackPosition: SnackPosition.BOTTOM); return; }
    if (_meterCtrl.text.isEmpty) { Get.snackbar('Error', 'Enter meter number', snackPosition: SnackPosition.BOTTOM); return; }
    final ok = await _svc.validateMeter(_svc.selectedDisco.value!.discoId, _meterCtrl.text.trim(), _meterType);
    if (ok) setState(() => _validated = true);
  }

  void _buy() {
    if (!_validated) { Get.snackbar('Error', 'Validate meter number first', snackPosition: SnackPosition.BOTTOM); return; }
    if (!_formKey.currentState!.validate()) return;
    if (_pin.length < 4) { Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
    _svc.purchase({
      'service_type': 'electricity',
      'disco_id': _svc.selectedDisco.value!.discoId,
      'meter_number': _meterCtrl.text.trim(),
      'meter_type': _meterType,
      'amount': double.tryParse(_amountCtrl.text) ?? 0,
      'transaction_pin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Electricity')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select DISCO', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Obx(() => _svc.discos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : AppDropdown<int>(
                      label: 'Distribution Company',
                      value: _svc.selectedDisco.value?.discoId,
                      items: _svc.discos.map((d) => DropdownMenuItem(value: d.discoId, child: Text(d.discoName))).toList(),
                      onChanged: (v) { _svc.selectedDisco.value = _svc.discos.firstWhereOrNull((d) => d.discoId == v); setState(() { _validated = false; _svc.validatedName.value = ''; }); },
                    )),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: RadioListTile<String>(title: const Text('Prepaid'), value: 'PREPAID', groupValue: _meterType,
                    onChanged: (v) => setState(() { _meterType = v!; _validated = false; _svc.validatedName.value = ''; }), dense: true)),
                Expanded(child: RadioListTile<String>(title: const Text('Postpaid'), value: 'POSTPAID', groupValue: _meterType,
                    onChanged: (v) => setState(() { _meterType = v!; _validated = false; _svc.validatedName.value = ''; }), dense: true)),
              ]),
              const SizedBox(height: 8),
              AppTextField(label: 'Meter Number', hint: 'Enter meter number', controller: _meterCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.electric_meter_outlined),
                  suffixIcon: Obx(() => _svc.isLoading.value
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : TextButton(onPressed: _validate, child: const Text('Verify')))),
              Obx(() => _svc.validatedName.value.isNotEmpty
                  ? Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(_svc.validatedName.value, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
                    ]))
                  : const SizedBox()),
              const SizedBox(height: 16),
              AppTextField(label: 'Amount (₦)', hint: '1000', controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.money),
                  validator: (v) => Validators.amount(v, min: 500)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [500, 1000, 2000, 5000].map((a) => ActionChip(label: Text('₦$a'), onPressed: () => _amountCtrl.text = a.toString())).toList()),
              const SizedBox(height: 20),
              TransactionPinField(onPinReady: (v) => _pin = v),
              const SizedBox(height: 24),
              Obx(() => AppButton(label: 'Pay Electricity', isLoading: _svc.isLoading.value, onPressed: _buy)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
