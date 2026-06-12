import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/storage.dart';
import '../../../core/utils/biometric_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricSupported = false;
  bool _biometricEnabled  = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final supported = await BiometricService.isSupported();
    final enrolled  = await BiometricService.hasEnrolled();
    final enabled   = await Storage.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricSupported = supported && enrolled;
        _biometricEnabled   = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value, AuthController auth) async {
    if (value) {
      // Need a PIN stored — check first
      final pin = await Storage.getSecurePin();
      if (pin == null || pin.isEmpty) {
        Get.snackbar(
          'PIN Required',
          'Log out and log back in to link your PIN with fingerprint.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }
    await auth.toggleBiometric(value);
    final enabled = await Storage.isBiometricEnabled();
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = home.user.value;
        if (user == null) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(16), children: [
          // Avatar + name
          Center(child: Column(children: [
            CircleAvatar(radius: 40, backgroundColor: AppColors.primary, child: Text(
              (user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U'),
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 12),
            Text(user.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('Verified', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12))),
          ])),
          const SizedBox(height: 24),
          // Stats row
          Row(children: [
            _statCard('Wallet', Helpers.formatCurrency(user.walletBalance), Icons.account_balance_wallet_outlined, AppColors.primary),
            const SizedBox(width: 12),
            _statCard('Referrals', '${user.referralCount}', Icons.people_outline, AppColors.secondary),
          ]),
          const SizedBox(height: 20),
          // Account info
          _section('Account Info', [
            _infoRow(Icons.person_outline, 'Username', user.username),
            _infoRow(Icons.email_outlined, 'Email', user.email),
            _infoRow(Icons.phone_outlined, 'Phone', user.phone),
            _infoRow(Icons.calendar_today_outlined, 'Joined', Helpers.formatShortDate(user.createdAt)),
          ]),
          const SizedBox(height: 16),
          // Menu
          _section('Settings', [
            _menuItem(Icons.lock_outline, 'Change PIN', () => Get.toNamed('/change-pin')),
            if (_biometricSupported)
              _switchItem(
                Icons.fingerprint,
                'Fingerprint Login',
                'Use fingerprint to log in and authorize transactions',
                _biometricEnabled,
                (v) => _toggleBiometric(v, auth),
              ),
            _menuItem(Icons.people_outline, 'Referrals', () => Get.toNamed('/referrals')),
            _menuItem(Icons.history, 'Transaction History', () => Get.toNamed('/history')),
            _menuItem(Icons.account_balance_outlined, 'Virtual Account', () => Get.toNamed('/virtual-account')),
          ]),
          const SizedBox(height: 16),
          _section('Support', [
            _menuItem(Icons.help_outline, 'Help & FAQ', () {}),
            _menuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          ]),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => _confirmLogout(context, auth),
          ),
          const SizedBox(height: 16),
        ]);
      }),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ]),
    ));
  }

  Widget _section(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary))),
        ...items,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _switchItem(IconData icon, String label, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { Navigator.pop(ctx); auth.logout(); }, child: const Text('Sign Out', style: TextStyle(color: AppColors.error))),
      ],
    ));
  }
}
