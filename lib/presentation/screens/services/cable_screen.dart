import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/transaction_pin_field.dart';

class CableScreen extends StatefulWidget {
  const CableScreen({super.key});
  @override
  State<CableScreen> createState() => _CableScreenState();
}

class _CableScreenState extends State<CableScreen> {
  final _iucCtrl  = TextEditingController();
  String _pin = '';
  bool _validated = false;
  late final ServiceController _svc;

  @override
  void initState() {
    super.initState();
    _svc = Get.find<ServiceController>();
    _svc.loadCables();
  }

  @override
  void dispose() { _iucCtrl.dispose(); super.dispose(); }

  Future<void> _validate() async {
    if (_svc.selectedCable.value == null) { Get.snackbar('Error', 'Select a cable provider', snackPosition: SnackPosition.BOTTOM); return; }
    if (_iucCtrl.text.isEmpty) { Get.snackbar('Error', 'Enter IUC/Smart Card number', snackPosition: SnackPosition.BOTTOM); return; }
    final ok = await _svc.validateIUC(_svc.selectedCable.value!.cableId, _iucCtrl.text.trim());
    if (ok) setState(() => _validated = true);
  }

  void _buy() {
    if (!_validated) { Get.snackbar('Error', 'Validate your IUC number first', snackPosition: SnackPosition.BOTTOM); return; }
    if (_svc.selectedCablePlan.value == null) { Get.snackbar('Error', 'Select a plan', snackPosition: SnackPosition.BOTTOM); return; }
    if (_pin.length < 4) { Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
    _svc.purchase({
      'service_type': 'cable',
      'cable_plan_id': _svc.selectedCablePlan.value!.cableplanId,
      'smart_card_number': _iucCtrl.text.trim(),
      'transaction_pin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cable TV')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Provider', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Obx(() => _svc.cables.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Wrap(spacing: 10, children: _svc.cables.map((c) => Obx(() => ChoiceChip(
                    label: Text(c.cableName),
                    selected: _svc.selectedCable.value?.cableId == c.cableId,
                    onSelected: (_) { _svc.selectedCable.value = c; _svc.loadCablePlans(c.cableId); setState(() { _validated = false; _svc.validatedName.value = ''; }); },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _svc.selectedCable.value?.cableId == c.cableId ? Colors.white : AppColors.textPrimary),
                  ))).toList())),
            const SizedBox(height: 20),
            AppTextField(label: 'IUC / Smart Card Number', hint: 'Enter your IUC number', controller: _iucCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card),
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
            const SizedBox(height: 20),
            Obx(() {
              if (_svc.cablePlans.isEmpty) return const SizedBox();
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._svc.cablePlans.map((p) => Obx(() => GestureDetector(
                  onTap: () => _svc.selectedCablePlan.value = p,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _svc.selectedCablePlan.value?.cableplanId == p.cableplanId ? AppColors.primary.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _svc.selectedCablePlan.value?.cableplanId == p.cableplanId ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(p.planName, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text('₦${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ]),
                  ),
                ))).toList(),
              ]);
            }),
            const SizedBox(height: 20),
            TransactionPinField(onPinReady: (v) => _pin = v),
            const SizedBox(height: 24),
            Obx(() => AppButton(label: 'Subscribe', isLoading: _svc.isLoading.value, onPressed: _buy)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
