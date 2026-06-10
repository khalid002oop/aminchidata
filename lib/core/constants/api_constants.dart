class ApiConstants {
  static const String baseUrl = 'https://aminchidata.com.ng/api';

  // Auth
  static const String login          = '/auth/login.php';
  static const String register       = '/auth/register.php';
  static const String verifyOtp      = '/auth/verify_otp.php';
  static const String resendOtp      = '/auth/resend_otp.php';
  static const String setupPin       = '/auth/setup_pin.php';
  static const String verifyPin      = '/auth/verify_pin.php';
  static const String forgotPassword = '/auth/forgot_password.php';
  static const String resetPassword  = '/auth/reset_password.php';

  // User
  static const String profile        = '/user/profile.php';
  static const String updateProfile  = '/user/update_profile.php';
  static const String changePin      = '/user/change_pin.php';
  static const String referrals      = '/user/referrals.php';
  static const String notifications  = '/user/notifications.php';

  // Services
  static const String dataPlans      = '/services/data_plans.php';
  static const String cable          = '/services/cable.php';
  static const String electricity    = '/services/electricity.php';
  static const String education      = '/services/education.php';
  static const String validate       = '/services/validate.php';

  // Transactions
  static const String purchase       = '/transactions/purchase.php';
  static const String history        = '/transactions/history.php';
  static const String receipt        = '/transactions/receipt.php';

  // Wallet
  static const String initPayment    = '/wallet/initialize_payment.php';
  static const String verifyPayment  = '/wallet/verify_payment.php';
  static const String virtualAccount = '/wallet/virtual_account.php';
}
