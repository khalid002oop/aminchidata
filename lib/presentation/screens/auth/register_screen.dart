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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Blue top bar
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0052CC), Color(0xFF0747A6)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Join AminchiData today', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.wifi_tethering_rounded, color: Colors.white54, size: 32),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Form card
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _sectionCard(children: [
                              AppTextField(label: 'Username', hint: 'johndoe', controller: _userCtrl,
                                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                                  validator: (v) => Validators.required(v, 'Username')),
                              const SizedBox(height: 14),
                              AppTextField(label: 'Email Address', hint: 'you@example.com', controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                  validator: Validators.email),
                              const SizedBox(height: 14),
                              AppTextField(label: 'Phone Number', hint: '08012345678', controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone, maxLength: 11,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                  validator: Validators.phone),
                            ]),
                            const SizedBox(height: 16),
                            _sectionCard(children: [
                              AppTextField(label: 'Password', controller: _passCtrl, isPassword: true,
                                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                  validator: Validators.password),
                              const SizedBox(height: 14),
                              AppTextField(label: 'Confirm Password', controller: _confCtrl, isPassword: true,
                                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                  validator: (v) => Validators.required(v, 'Confirm Password')),
                            ]),
                            const SizedBox(height: 16),
                            _sectionCard(children: [
                              AppTextField(
                                label: 'Referral Code (Optional)',
                                hint: 'Leave empty if none',
                                controller: _refCtrl,
                                prefixIcon: const Icon(Icons.card_giftcard_outlined, size: 20),
                              ),
                            ]),
                            const SizedBox(height: 28),
                            Obx(() => AppButton(
                              label: 'Create Account',
                              onPressed: _submit,
                              isLoading: Get.find<AuthController>().isLoading.value,
                            )),
                            const SizedBox(height: 20),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
