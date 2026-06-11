import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/storage.dart';
import '../utils/biometric_service.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  ApiResponse({required this.success, required this.message, this.data});
}

class ApiClient {
  static bool _reauthInProgress = false;

  static Future<Map<String, String>> _headers({bool auth = true, String? overrideToken}) async {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (auth) {
      final token = overrideToken ?? await Storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static ApiResponse _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      // 401 triggers a global session-expiry dialog (only once at a time)
      if (res.statusCode == 401 && !_reauthInProgress) {
        _showSessionExpiredDialog();
      }
      return ApiResponse(
        success: body['success'] == true,
        message: body['message'] ?? '',
        data: body['data'],
      );
    } catch (_) {
      return ApiResponse(success: false, message: 'Server error. Please try again.', data: null);
    }
  }

  static Future<ApiResponse> get(String path, {Map<String, String>? query, String? token}) async {
    var uri = Uri.parse(ApiConstants.baseUrl + path);
    if (query != null && query.isNotEmpty) uri = uri.replace(queryParameters: query);
    try {
      final res = await http.get(uri, headers: await _headers(overrideToken: token))
          .timeout(const Duration(seconds: 30));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error. Check your connection.', data: null);
    }
  }

  static Future<ApiResponse> post(String path, Map<String, dynamic> body,
      {bool auth = true, String? token}) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    try {
      final res = await http
          .post(uri, headers: await _headers(auth: auth, overrideToken: token), body: jsonEncode(body))
          .timeout(const Duration(seconds: 60));
      return _parse(res);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error. Check your connection.', data: null);
    }
  }

  // ── Session-expiry re-auth dialog ────────────────────────────────────────
  static void _showSessionExpiredDialog() {
    _reauthInProgress = true;
    final pinCtrl = TextEditingController();
    final loading = false.obs;
    final error   = ''.obs;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.lock_outline, color: Color(0xFF2ecc71)),
            SizedBox(width: 8),
            Text('Session Expired', style: TextStyle(fontSize: 16)),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Enter your transaction PIN to continue.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              Obx(() => TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: '••••',
                  errorText: error.value.isEmpty ? null : error.value,
                ),
              )),
              const SizedBox(height: 8),
              // Fingerprint option
              FutureBuilder<bool>(
                future: BiometricService.isReadyForLogin(),
                builder: (_, snap) {
                  if (snap.data != true) return const SizedBox();
                  return TextButton.icon(
                    icon: const Icon(Icons.fingerprint, color: Color(0xFF2ecc71)),
                    label: const Text('Use Fingerprint', style: TextStyle(color: Color(0xFF2ecc71))),
                    onPressed: () async {
                      final ok = await BiometricService.authenticate(
                          reason: 'Verify your identity to continue');
                      if (ok) {
                        final pin = await Storage.getSecurePin();
                        if (pin != null) pinCtrl.text = pin;
                      }
                    },
                  );
                },
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _reauthInProgress = false;
                Get.back();
                Get.offAllNamed('/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
            Obx(() => loading.value
                ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ecc71), foregroundColor: Colors.white),
                    onPressed: () async {
                      final pin = pinCtrl.text.trim();
                      if (pin.length < 4) { error.value = 'Enter your 4-digit PIN'; return; }
                      final email = await Storage.getEmail();
                      if (email == null) {
                        _reauthInProgress = false;
                        Get.back();
                        Get.offAllNamed('/login');
                        return;
                      }
                      loading.value = true;
                      error.value = '';
                      final res = await ApiClient.post(
                        ApiConstants.reauth, {'email': email, 'pin': pin}, auth: false);
                      loading.value = false;
                      if (res.success) {
                        await Storage.saveToken(res.data['token'], scope: 'full');
                        _reauthInProgress = false;
                        Get.back();
                        Get.snackbar('Session restored', 'You are now logged in.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2ecc71),
                            colorText: Colors.white);
                      } else {
                        error.value = res.message;
                      }
                    },
                    child: const Text('Confirm'),
                  )),
          ],
        ),
      ),
      barrierDismissible: false,
    ).then((_) => _reauthInProgress = false);
  }
}
