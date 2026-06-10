import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _userCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  final _refCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ref = Get.parameters['ref'] ?? '';
    if (ref.isNotEmpty) _refCtrl.text = ref;
  }

  @override
  void dispose() {
    _userCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose(); _refCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_passCtrl.text != _confCtrl.text) {
        Get.snackbar('Error', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Get.find<AuthController>().register(
        _userCtrl.text.trim(), _emailCtrl.text.trim(),
        _phoneCtrl.text.trim(), _passCtrl.text,
        referralCode: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              AppTextField(label: 'Username', hint: 'johndoe', controller: _userCtrl,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => Validators.required(v, 'Username')),
              const SizedBox(height: 16),
              AppTextField(label: 'Email', hint: 'you@example.com', controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email),
              const SizedBox(height: 16),
              AppTextField(label: 'Phone Number', hint: '08012345678', controller: _phoneCtrl,
                  keyboardType: TextInputType.phone, maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.phone_outlined), validator: Validators.phone),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _passCtrl, isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline), validator: Validators.password),
              const SizedBox(height: 16),
              AppTextField(label: 'Confirm Password', controller: _confCtrl, isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) => Validators.required(v, 'Confirm Password')),
              const SizedBox(height: 16),
              AppTextField(label: 'Referral Code (Optional)', hint: 'Leave empty if none',
                  controller: _refCtrl, prefixIcon: const Icon(Icons.card_giftcard_outlined)),
              const SizedBox(height: 32),
              Obx(() => AppButton(label: 'Create Account', onPressed: _submit,
                  isLoading: Get.find<AuthController>().isLoading.value)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                GestureDetector(onTap: () => Get.back(), child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
