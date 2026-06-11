import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage.dart';
import '../../core/utils/biometric_service.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final isLoading      = false.obs;
  final biometricReady = false.obs;
  String? _pendingToken;

  void _setLoading(bool v) => isLoading.value = v;
  void _showError(String msg) =>
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
  void _showSuccess(String msg) =>
      Get.snackbar('Success', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));

  Future<void> login(String email, String password) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.login, {'email': email, 'password': password}, auth: false);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }

    final data = res.data as Map<String, dynamic>;
    _pendingToken = data['token'];
    await Storage.saveToken(_pendingToken!, scope: data['next_step'] ?? 'full');
    await Storage.saveEmail(email);

    switch (data['next_step']) {
      case 'setup_pin':
        Get.toNamed(AppRoutes.setupPin, arguments: {'token': _pendingToken});
        break;
      case 'verify_pin':
        Get.toNamed(AppRoutes.verifyPin, arguments: {'token': _pendingToken, 'username': data['username']});
        break;
      default:
        Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> register(String username, String email, String phone, String password, {String? referralCode}) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.register, {
      'username': username, 'email': email, 'phone': phone, 'password': password,
      if (referralCode != null && referralCode.isNotEmpty) 'referral_code': referralCode,
    }, auth: false);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }

    final data = res.data as Map<String, dynamic>;
    _pendingToken = data['token'];
    final nextStep = data['next_step'] ?? 'setup_pin';
    await Storage.saveToken(_pendingToken!, scope: nextStep);
    await Storage.saveEmail(email);

    switch (nextStep) {
      case 'verify_pin':
        Get.offAllNamed(AppRoutes.verifyPin, arguments: {'token': _pendingToken, 'username': data['username']});
        break;
      default:
        Get.offAllNamed(AppRoutes.setupPin, arguments: {'token': _pendingToken});
    }
  }

  Future<void> verifyOtp(String otp, {String? token, String? email}) async {
    final t = token ?? _pendingToken;
    if (t == null) { _showError('Session expired. Please log in again.'); Get.offAllNamed(AppRoutes.login); return; }
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.verifyOtp, {'otp': otp}, token: t);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }
    final data = res.data as Map<String, dynamic>;
    _pendingToken = data['token'];
    await Storage.saveToken(_pendingToken!, scope: data['next_step'] ?? '');
    if (data['next_step'] == 'setup_pin') {
      Get.offNamed(AppRoutes.setupPin, arguments: {'token': _pendingToken});
    } else {
      Get.offNamed(AppRoutes.verifyPin, arguments: {'token': _pendingToken});
    }
  }

  Future<void> resendOtp(String email) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.resendOtp, {'email': email}, auth: false);
    _setLoading(false);
    if (res.success) { _showSuccess('OTP sent! Check your email.'); } else { _showError(res.message); }
  }

  Future<void> setupPin(String pin, {String? token}) async {
    final t = token ?? _pendingToken;
    if (t == null) { Get.offAllNamed(AppRoutes.login); return; }
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.setupPin, {'pin': pin}, token: t);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }
    await _completeLogin(res.data as Map<String, dynamic>, pin: pin);
  }

  Future<void> verifyPin(String pin, {String? token}) async {
    final t = token ?? _pendingToken;
    if (t == null) { Get.offAllNamed(AppRoutes.login); return; }
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.verifyPin, {'pin': pin}, token: t);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }
    await _completeLogin(res.data as Map<String, dynamic>, pin: pin);
  }

  Future<void> _completeLogin(Map<String, dynamic> data, {String? pin}) async {
    await Storage.saveToken(data['token'], scope: 'full');
    if (data['user'] != null) await Storage.saveUserData(jsonEncode(data['user']));

    // If biometric available + not yet set up, save PIN and offer to enable
    if (pin != null) {
      final supported = await BiometricService.isSupported();
      final enrolled  = await BiometricService.hasEnrolled();
      final alreadyEnabled = await Storage.isBiometricEnabled();
      if (supported && enrolled && !alreadyEnabled) {
        await Storage.saveSecurePin(pin);
        await _offerBiometric();
      } else if (alreadyEnabled) {
        // Update the stored PIN whenever user re-verifies
        await Storage.saveSecurePin(pin);
      }
    }

    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _offerBiometric() async {
    final enable = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Text('🔒 '), Text('Enable Fingerprint Login?', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          'Use your fingerprint to log in and authorize transactions faster — no PIN typing needed.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Not Now')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ecc71), foregroundColor: Colors.white),
            onPressed: () => Get.back(result: true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (enable == true) {
      await Storage.setBiometricEnabled(true);
      biometricReady.value = true;
    }
  }

  // Called from settings/profile to toggle fingerprint
  Future<void> toggleBiometric(bool enable) async {
    if (enable) {
      final ok = await BiometricService.authenticate(reason: 'Confirm your identity to enable fingerprint');
      if (ok) {
        await Storage.setBiometricEnabled(true);
        biometricReady.value = true;
        _showSuccess('Fingerprint login enabled.');
      }
    } else {
      await Storage.setBiometricEnabled(false);
      await Storage.clearSecurePin();
      biometricReady.value = false;
      _showSuccess('Fingerprint login disabled.');
    }
  }

  Future<void> forgotPassword(String email) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.forgotPassword, {'email': email}, auth: false);
    _setLoading(false);
    if (res.success) {
      _showSuccess('Reset code sent to your email.');
      Get.toNamed(AppRoutes.resetPassword, arguments: {'email': email});
    } else {
      _showError(res.message);
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.resetPassword, {'email': email, 'otp': otp, 'password': password}, auth: false);
    _setLoading(false);
    if (res.success) {
      _showSuccess('Password reset! Please log in.');
      Get.offAllNamed(AppRoutes.login);
    } else {
      _showError(res.message);
    }
  }

  Future<void> logout() async {
    await Storage.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
