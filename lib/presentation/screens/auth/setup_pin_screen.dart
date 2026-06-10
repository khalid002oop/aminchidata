import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/pin_input.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});
  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String _confirm = '';
  bool _step2 = false;
  late String? _token;

  @override
  void initState() {
    super.initState();
    _token = (Get.arguments as Map<String, dynamic>?)?['token'];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.pin_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(_step2 ? 'Confirm Your PIN' : 'Set Transaction PIN',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_step2 ? 'Enter PIN again to confirm' : 'Create a 4-digit PIN for all transactions',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              PinInput(
                key: ValueKey(_step2),
                onChanged: (v) => _step2 ? _confirm = v : _pin = v,
                onCompleted: (v) => _step2 ? _confirm = v : _pin = v,
              ),
              const SizedBox(height: 40),
              Obx(() => AppButton(
                label: _step2 ? 'Confirm & Continue' : 'Next',
                isLoading: auth.isLoading.value,
                onPressed: () {
                  if (!_step2) {
                    if (_pin.length == 4) setState(() => _step2 = true);
                    else Get.snackbar('Error', 'Enter 4-digit PIN', snackPosition: SnackPosition.BOTTOM);
                  } else {
                    if (_confirm.length < 4) { Get.snackbar('Error', 'Enter 4-digit PIN', snackPosition: SnackPosition.BOTTOM); return; }
                    if (_pin != _confirm) {
                      Get.snackbar('Error', 'PINs do not match. Try again.', snackPosition: SnackPosition.BOTTOM);
                      setState(() { _pin = ''; _confirm = ''; _step2 = false; });
                      return;
                    }
                    auth.setupPin(_pin, token: _token);
                  }
                },
              )),
              if (_step2) ...[
                const SizedBox(height: 16),
                TextButton(onPressed: () => setState(() { _step2 = false; _pin = ''; _confirm = ''; }),
                    child: const Text('← Change PIN', style: TextStyle(color: AppColors.primary))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
