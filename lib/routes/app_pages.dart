import 'package:get/get.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/otp_screen.dart';
import '../presentation/screens/auth/setup_pin_screen.dart';
import '../presentation/screens/auth/verify_pin_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/reset_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/services/data_screen.dart';
import '../presentation/screens/services/airtime_screen.dart';
import '../presentation/screens/services/cable_screen.dart';
import '../presentation/screens/services/electricity_screen.dart';
import '../presentation/screens/services/education_screen.dart';
import '../presentation/screens/wallet/fund_wallet_screen.dart';
import '../presentation/screens/wallet/virtual_account_screen.dart';
import '../presentation/screens/transactions/history_screen.dart';
import '../presentation/screens/transactions/receipt_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/referrals_screen.dart';
import '../presentation/screens/profile/change_pin_screen.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/service_controller.dart';
import '../presentation/controllers/transaction_controller.dart';
import '../presentation/controllers/wallet_controller.dart';

class AppRoutes {
  static const login          = '/login';
  static const register       = '/register';
  static const otp            = '/otp';
  static const setupPin       = '/setup-pin';
  static const verifyPin      = '/verify-pin';
  static const forgotPassword = '/forgot-password';
  static const resetPassword  = '/reset-password';
  static const home           = '/home';
  static const buyData        = '/buy-data';
  static const buyAirtime     = '/buy-airtime';
  static const buyCable       = '/buy-cable';
  static const buyElectricity = '/buy-electricity';
  static const buyEducation   = '/buy-education';
  static const fundWallet     = '/fund-wallet';
  static const virtualAccount = '/virtual-account';
  static const history        = '/history';
  static const receipt        = '/receipt';
  static const profile        = '/profile';
  static const referrals      = '/referrals';
  static const changePin      = '/change-pin';
}

final appPages = [
  GetPage(name: AppRoutes.login,          page: () => const LoginScreen(),          binding: BindingsBuilder(() => Get.put(AuthController()))),
  GetPage(name: AppRoutes.register,       page: () => const RegisterScreen()),
  GetPage(name: AppRoutes.otp,            page: () => const OtpScreen()),
  GetPage(name: AppRoutes.setupPin,       page: () => const SetupPinScreen()),
  GetPage(name: AppRoutes.verifyPin,      page: () => const VerifyPinScreen()),
  GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordScreen()),
  GetPage(name: AppRoutes.resetPassword,  page: () => const ResetPasswordScreen()),
  GetPage(name: AppRoutes.home,           page: () => const HomeScreen(),            binding: BindingsBuilder(() {
    Get.put(AuthController(), permanent: true);
    Get.put(HomeController());
    Get.put(ServiceController());
    Get.put(TransactionController());
    Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.buyData,        page: () => const DataScreen()),
  GetPage(name: AppRoutes.buyAirtime,     page: () => const AirtimeScreen()),
  GetPage(name: AppRoutes.buyCable,       page: () => const CableScreen()),
  GetPage(name: AppRoutes.buyElectricity, page: () => const ElectricityScreen()),
  GetPage(name: AppRoutes.buyEducation,   page: () => const EducationScreen()),
  GetPage(name: AppRoutes.fundWallet,     page: () => const FundWalletScreen()),
  GetPage(name: AppRoutes.virtualAccount, page: () => const VirtualAccountScreen()),
  GetPage(name: AppRoutes.history,        page: () => const HistoryScreen()),
  GetPage(name: AppRoutes.receipt,        page: () => ReceiptScreen(tid: Get.arguments as String? ?? '')),
  GetPage(name: AppRoutes.profile,        page: () => const ProfileScreen()),
  GetPage(name: AppRoutes.referrals,      page: () => const ReferralsScreen()),
  GetPage(name: AppRoutes.changePin,      page: () => const ChangePinScreen()),
];
