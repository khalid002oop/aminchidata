import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage.dart';
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
      Get.offAllNamed(AppRoutes.login);
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
        Get.offAllNamed(AppRoutes.home);
        break;
      default:
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
