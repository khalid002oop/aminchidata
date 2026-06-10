import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/pin_input.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  late String _email;
  late String? _token;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _email = args['email'] ?? '';
    _token = args['token'];
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify Email'), backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('Enter the code sent to your email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_email, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            PinInput(
              length: 6,
              onChanged: (v) => _otp = v,
              onCompleted: (v) { _otp = v; },
            ),
            const SizedBox(height: 32),
            Obx(() => AppButton(
              label: 'Verify OTP',
              isLoading: auth.isLoading.value,
              onPressed: () {
                if (_otp.length == 6) {
                  auth.verifyOtp(_otp, token: _token, email: _email);
                } else {
                  Get.snackbar('Error', 'Enter the 6-digit OTP', snackPosition: SnackPosition.BOTTOM);
                }
              },
            )),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => auth.resendOtp(_email),
                child: const Text("Didn't receive it? Resend OTP", style: TextStyle(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
