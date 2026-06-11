import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/biometric_service.dart';
import '../../../core/utils/storage.dart';
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
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _token    = args['token'];
    _username = args['username'] ?? '';
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final ready = await BiometricService.isReadyForLogin();
    if (mounted) setState(() => _biometricAvailable = ready);
    if (ready) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final ok = await BiometricService.authenticate(
        reason: 'Use fingerprint to verify your identity');
    if (!ok || !mounted) return;
    final pin = await Storage.getSecurePin();
    if (pin != null && pin.isNotEmpty) {
      setState(() => _pin = pin);
      // Small delay so the user sees the PIN dots fill in
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Get.find<AuthController>().verifyPin(pin, token: _token);
    }
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
              const Text('Enter your 4-digit transaction PIN to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              PinInput(onChanged: (v) => _pin = v, onCompleted: (v) => _pin = v),
              const SizedBox(height: 24),
              if (_biometricAvailable) ...[
                GestureDetector(
                  onTap: _tryBiometric,
                  child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fingerprint, size: 38, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    const Text('Use Fingerprint',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
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
                child: const Text('Sign in with a different account',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
