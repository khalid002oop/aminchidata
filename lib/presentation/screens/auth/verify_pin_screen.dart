import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/pin_input.dart';
import '../../../routes/app_pages.dart';

class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({super.key});
  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  String _pin = '';
  String _username = '';
  String? _token;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _token    = args['token'];
    _username = args['username'] ?? '';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Welcome${_username.isNotEmpty ? ", $_username" : ""}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter your 4-digit transaction PIN to continue', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              PinInput(onChanged: (v) => _pin = v, onCompleted: (v) => _pin = v),
              const SizedBox(height: 40),
              Obx(() => AppButton(
                label: 'Continue',
                isLoading: auth.isLoading.value,
                onPressed: () {
                  if (_pin.length == 4) auth.verifyPin(_pin, token: _token);
                  else Get.snackbar('Error', 'Enter your 4-digit PIN', snackPosition: SnackPosition.BOTTOM);
                },
              )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                child: const Text('Sign in with a different account', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
