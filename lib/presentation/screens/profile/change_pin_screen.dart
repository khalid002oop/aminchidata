import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage.dart';
import '../../widgets/app_button.dart';
import '../../widgets/pin_input.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});
  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String _oldPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _loading = false;

  Future<void> _submit() async {
    if (_oldPin.length < 4) { Get.snackbar('Error', 'Enter your current PIN'); return; }
    if (_newPin.length < 4) { Get.snackbar('Error', 'Enter a new 4-digit PIN'); return; }
    if (_newPin != _confirmPin) { Get.snackbar('Error', 'New PINs do not match'); return; }

    setState(() => _loading = true);
    final token = await Storage.getToken();
    final res = await ApiClient.post(ApiConstants.changePin, {'old_pin': _oldPin, 'new_pin': _newPin}, token: token);
    setState(() => _loading = false);

    if (res.success) {
      Get.snackbar('Success', 'PIN changed successfully', backgroundColor: AppColors.success, colorText: Colors.white);
      Get.back();
    } else {
      Get.snackbar('Failed', res.message, backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Transaction PIN')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const CircleAvatar(radius: 36, backgroundColor: Color(0xFFE8F0FE), child: Icon(Icons.lock_reset, color: AppColors.primary, size: 36)),
          const SizedBox(height: 16),
          const Text('Change Your PIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter your current PIN, then set a new one.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          const Align(alignment: Alignment.centerLeft, child: Text('Current PIN', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          PinInput(length: 4, onCompleted: (v) => setState(() => _oldPin = v)),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('New PIN', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          PinInput(length: 4, onCompleted: (v) => setState(() => _newPin = v)),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('Confirm New PIN', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          PinInput(length: 4, onCompleted: (v) => setState(() => _confirmPin = v)),
          const SizedBox(height: 32),
          AppButton(label: 'Update PIN', isLoading: _loading, onPressed: _submit),
        ]),
      ),
    );
  }
}
