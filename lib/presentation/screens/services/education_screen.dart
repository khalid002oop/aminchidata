import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/service_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/transaction_pin_field.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _qty = 1;
  String _pin = '';
  late final ServiceController _svc;

  @override
  void initState() { super.initState(); _svc = Get.find<ServiceController>(); _svc.loadExams(); }

  void _buy() {
    if (_svc.selectedExam.value == null) { Get.snackbar('Error', 'Select an exam', snackPosition: SnackPosition.BOTTOM); return; }
    if (_pin.length < 4) { Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
    _svc.purchase({
      'service_type': 'education',
      'exam_id': _svc.selectedExam.value!.examId,
      'quantity': _qty,
      'transaction_pin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Education Pins')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Exam', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Obx(() => _svc.exams.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(children: _svc.exams.map((e) => Obx(() => GestureDetector(
                    onTap: () => _svc.selectedExam.value = e,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _svc.selectedExam.value?.examId == e.examId ? AppColors.primary.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _svc.selectedExam.value?.examId == e.examId ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(e.examName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('₦${e.amount.toStringAsFixed(0)}/pin', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ]),
                    ),
                  ))).toList())),
            const SizedBox(height: 20),
            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(onPressed: () { if (_qty > 1) setState(() => _qty--); }, icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary)),
              Text('$_qty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () { if (_qty < 5) setState(() => _qty++); }, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
              const SizedBox(width: 8),
              Obx(() => _svc.selectedExam.value != null
                  ? Text('Total: ₦${(_svc.selectedExam.value!.amount * _qty).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))
                  : const SizedBox()),
            ]),
            const SizedBox(height: 20),
            TransactionPinField(onPinReady: (v) => _pin = v),
            const SizedBox(height: 24),
            Obx(() => AppButton(label: 'Buy PIN(s)', isLoading: _svc.isLoading.value, onPressed: _buy)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
