import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/transaction_pin_field.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String _pin = '';
  late final ServiceController _svc;

  final _networks = ['MTN', 'GLO', 'AIRTEL', '9MOBILE'];
  final _networkColors = {'MTN': const Color(0xFFFFCC00), 'GLO': const Color(0xFF00A651), 'AIRTEL': const Color(0xFFFF0000), '9MOBILE': const Color(0xFF006633)};

  @override
  void initState() {
    super.initState();
    _svc = Get.find<ServiceController>();
    _svc.networks.value = _networks;
  }

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  void _buy() {
    if (!_formKey.currentState!.validate()) return;
    if (_svc.selectedPlan.value == null) { Get.snackbar('Error', 'Select a data plan', snackPosition: SnackPosition.BOTTOM); return; }
    if (_pin.length < 4) { Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
    _svc.purchase({
      'service_type': 'data',
      'network': _svc.selectedNetwork.value,
      'plan_id': _svc.selectedPlan.value!.planId,
      'phone': _phoneCtrl.text.trim(),
      'transaction_pin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Data')),
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
                children: _networks.map((n) => Obx(() => GestureDetector(
                  onTap: () => _svc.loadPlanTypes(n),
                  child: Column(children: [
                    Container(width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: _svc.selectedNetwork.value == n ? (_networkColors[n] ?? AppColors.primary) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: _svc.selectedNetwork.value == n ? Border.all(color: _networkColors[n] ?? AppColors.primary, width: 2) : null,
                      ),
                      child: Center(child: Text(n, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _svc.selectedNetwork.value == n ? Colors.white : Colors.grey.shade700))),
                    ),
                  ]),
                ))).toList(),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (_svc.planTypes.isEmpty) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Plan Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: _svc.planTypes.map((t) => Obx(() => ChoiceChip(
                    label: Text(t),
                    selected: _svc.selectedType.value == t,
                    onSelected: (_) => _svc.loadPlans(_svc.selectedNetwork.value, t),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: _svc.selectedType.value == t ? Colors.white : AppColors.textPrimary),
                  ))).toList()),
                  const SizedBox(height: 20),
                ]);
              }),
              Obx(() {
                if (_svc.dataPlans.isEmpty) return const SizedBox();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._svc.dataPlans.map((plan) => Obx(() => GestureDetector(
                    onTap: () => _svc.selectedPlan.value = plan,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _svc.selectedPlan.value?.planId == plan.planId ? AppColors.primary.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _svc.selectedPlan.value?.planId == plan.planId ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${plan.size} — ${plan.validity}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('₦${plan.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ]),
                    ),
                  ))).toList(),
                  const SizedBox(height: 20),
                ]);
              }),
              AppTextField(label: 'Phone Number', hint: '08012345678', controller: _phoneCtrl,
                  keyboardType: TextInputType.phone, maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.phone_outlined), validator: Validators.phone),
              const SizedBox(height: 20),
              TransactionPinField(onPinReady: (v) => _pin = v),
              const SizedBox(height: 24),
              Obx(() => AppButton(label: 'Buy Data', isLoading: _svc.isLoading.value, onPressed: _buy)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
