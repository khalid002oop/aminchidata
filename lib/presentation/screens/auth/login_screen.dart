import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../../routes/app_pages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Sign in to your AminchiData account', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: Validators.password,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => AppButton(label: 'Sign In', onPressed: _submit, isLoading: _auth.isLoading.value)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
