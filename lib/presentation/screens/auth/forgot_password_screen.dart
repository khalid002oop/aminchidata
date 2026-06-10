import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password'), backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Reset Your Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter your email and we\'ll send a reset code', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              AppTextField(label: 'Email Address', hint: 'you@example.com', controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email),
              const SizedBox(height: 32),
              Obx(() => AppButton(label: 'Send Reset Code', isLoading: auth.isLoading.value,
                  onPressed: () { if (_formKey.currentState!.validate()) auth.forgotPassword(_emailCtrl.text.trim()); })),
            ],
          ),
        ),
      ),
    );
  }
}
