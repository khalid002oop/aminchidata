import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage.dart';
import 'core/utils/biometric_service.dart';
import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'routes/app_pages.dart';
import 'presentation/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AminchiDataApp());
}

class AminchiDataApp extends StatelessWidget {
  const AminchiDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AminchiData',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      getPages: appPages,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>    _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await Storage.getToken();
    final scope = await Storage.getScope();

    if (token == null || token.isEmpty) {
      // No token — try biometric login if available
      await _tryBiometricLogin();
      return;
    }

    switch (scope) {
      case 'setup_pin':
      case 'pin_setup':
        Get.offAllNamed(AppRoutes.setupPin);
        break;
      case 'verify_pin':
      case 'pin_verify':
        Get.offAllNamed(AppRoutes.verifyPin);
        break;
      case 'full':
        // Valid full token — go home directly
        Get.offAllNamed(AppRoutes.home);
        break;
      default:
        // Unknown scope or expired — try biometric then login
        await _tryBiometricLogin();
    }
  }

  Future<void> _tryBiometricLogin() async {
    final ready = await BiometricService.isReadyForLogin();
    if (!ready) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final ok = await BiometricService.authenticate(
        reason: 'Use fingerprint to sign in to AminchiData');
    if (!ok) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Biometric success — reauth with stored PIN
    final email = await Storage.getEmail();
    final pin   = await Storage.getSecurePin();
    if (email == null || pin == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final res = await ApiClient.post(
        ApiConstants.reauth, {'email': email, 'pin': pin}, auth: false);
    if (res.success) {
      await Storage.saveToken(res.data['token'], scope: 'full');
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fade,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: Text('AC', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary))),
          ),
          const SizedBox(height: 20),
          const Text('AminchiData', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Fast. Reliable. Affordable.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 60),
          const CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
        ])),
      ),
    );
  }
}
