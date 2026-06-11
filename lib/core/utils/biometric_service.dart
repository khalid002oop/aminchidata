import 'package:local_auth/local_auth.dart';
import 'storage.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasEnrolled() async {
    try {
      final list = await _auth.getAvailableBiometrics();
      return list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // True only if device supports biometric AND user has enabled it in the app
  static Future<bool> isReadyForLogin() async {
    if (!await isSupported()) return false;
    if (!await hasEnrolled()) return false;
    if (!await Storage.isBiometricEnabled()) return false;
    final pin = await Storage.getSecurePin();
    return pin != null && pin.isNotEmpty;
  }

  static Future<bool> authenticate({String reason = 'Verify your identity to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
