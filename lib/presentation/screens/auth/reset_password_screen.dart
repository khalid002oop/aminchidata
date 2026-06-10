import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/pin_input.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  String _otp = '';
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = (Get.arguments as Map<String, dynamic>?)?['email'] ?? '';
  }

  @override
  void dispose() { _passCtrl.dispose(); _confCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('Enter OTP from your email', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              PinInput(length: 6, onChanged: (v) => _otp = v, onCompleted: (v) => _otp = v),
              const SizedBox(height: 24),
              AppTextField(label: 'New Password', controller: _passCtrl, isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline), validator: Validators.password),
              const SizedBox(height: 16),
              AppTextField(label: 'Confirm New Password', controller: _confCtrl, isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
              const SizedBox(height: 32),
              Obx(() => AppButton(label: 'Reset Password', isLoading: auth.isLoading.value, onPressed: () {
                if (_otp.length < 6) { Get.snackbar('Error', 'Enter the 6-digit OTP', snackPosition: SnackPosition.BOTTOM); return; }
                if (_formKey.currentState!.validate()) auth.resetPassword(_email, _otp, _passCtrl.text);
              })),
            ],
          ),
        ),
      ),
    );
  }
}
