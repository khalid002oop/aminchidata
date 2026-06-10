import 'dart:convert';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage.dart';
import '../../routes/app_pages.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  String? _pendingToken;
  String? _pendingEmail;

  void _setLoading(bool v) => isLoading.value = v;

  void _showError(String msg) => Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
  void _showSuccess(String msg) => Get.snackbar('Success', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));

  Future<void> login(String email, String password) async {
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.login, {'email': email, 'password': password}, auth: false);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }

    final data = res.data as Map<String, dynamic>;
    _pendingToken = data['token'];
    _pendingEmail = email;
    await Storage.saveToken(_pendingToken!, scope: data['next_step'] ?? '');

    switch (data['next_step']) {
      case 'verify_otp':
        Get.toNamed(AppRoutes.otp, arguments: {'email': _pendingEmail, 'token': _pendingToken});
        break;
      case 'setup_pin':
        Get.toNamed(AppRoutes.setupPin, arguments: {'token': _pendingToken});
        break;
      case 'verify_pin':
        Get.toNamed(AppRoutes.verifyPin, arguments: {'token': _pendingToken, 'username': data['username']});
        break;
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
    _pendingEmail = email;
    await Storage.saveToken(_pendingToken!, scope: 'otp_verify');
    Get.toNamed(AppRoutes.otp, arguments: {'email': email, 'token': _pendingToken});
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
    await _completeLogin(res.data as Map<String, dynamic>);
  }

  Future<void> verifyPin(String pin, {String? token}) async {
    final t = token ?? _pendingToken;
    if (t == null) { Get.offAllNamed(AppRoutes.login); return; }
    _setLoading(true);
    final res = await ApiClient.post(ApiConstants.verifyPin, {'pin': pin}, token: t);
    _setLoading(false);
    if (!res.success) { _showError(res.message); return; }
    await _completeLogin(res.data as Map<String, dynamic>);
  }

  Future<void> _completeLogin(Map<String, dynamic> data) async {
    await Storage.saveToken(data['token'], scope: 'full');
    if (data['user'] != null) {
      await Storage.saveUserData(jsonEncode(data['user']));
    }
    Get.offAllNamed(AppRoutes.home);
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
