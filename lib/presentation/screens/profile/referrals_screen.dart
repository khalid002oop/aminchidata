import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../controllers/home_controller.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});
  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  late final HomeController _home;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _home = Get.find<HomeController>();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() => _loading = true);
    // Referral data comes from the profile endpoint; just use home data
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Referrals')),
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = _home.user.value;
        if (user == null) return const Center(child: CircularProgressIndicator());

        final code = user.referralCode ?? '';
        final link = 'https://aminchidata.com.ng/register?ref=$code';

        return ListView(padding: const EdgeInsets.all(16), children: [
          // Earnings banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              const Text('Total Referral Earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(Helpers.formatCurrency(user.referralEarnings),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.people, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text('${user.referralCount} referrals', style: const TextStyle(color: Colors.white70)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Referral code card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your Referral Code', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text(code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3, color: AppColors.primary)),
                )),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.primary),
                  onPressed: () { Clipboard.setData(ClipboardData(text: code)); Get.snackbar('Copied', 'Referral code copied', backgroundColor: Colors.black87, colorText: Colors.white); },
                ),
              ]),
              const SizedBox(height: 12),
              const Text('Referral Link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: Text(link, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.copy, size: 18, color: AppColors.primary), onPressed: () {
                  Clipboard.setData(ClipboardData(text: link));
                  Get.snackbar('Copied', 'Referral link copied', backgroundColor: Colors.black87, colorText: Colors.white);
                }),
              ]),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Row(children: [
                Icon(Icons.info_outline, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('Earn bonus credit for every friend who registers and funds their wallet using your code.', style: TextStyle(fontSize: 12, color: Colors.green))),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Referred Users', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (user.referralCount == 0)
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Column(children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No referrals yet', style: TextStyle(color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('Share your code to start earning!', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            )
          else
            const Center(child: Text('Share your code to see referrals here.', style: TextStyle(color: AppColors.textSecondary))),
        ]);
      }),
    );
  }
}
