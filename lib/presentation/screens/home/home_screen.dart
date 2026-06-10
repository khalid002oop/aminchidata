import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../../routes/app_pages.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (home.isLoading.value && home.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: home.loadDashboard,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                snap: true,
                backgroundColor: AppColors.primary,
                title: Obx(() => Text('Hi, ${home.user.value?.username ?? ""}! 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
                actions: [
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => _showNotifications(context, home)),
                  IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: () => Get.toNamed(AppRoutes.profile)),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => BalanceCard(
                        balance:       home.user.value?.walletBalance ?? 0,
                        visible:       home.balanceVisible.value,
                        onToggle:      home.toggleBalanceVisibility,
                        accountNumber: home.user.value?.virtualAccount?.accountNumber,
                        bankName:      home.user.value?.virtualAccount?.bankName,
                        onFund:        () => Get.toNamed(AppRoutes.fundWallet),
                      )),
                      const SizedBox(height: 24),
                      const Text('Quick Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _ServicesGrid(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton(onPressed: () => Get.toNamed(AppRoutes.history), child: const Text('See All')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (home.recentTxns.isEmpty) {
                          return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary))));
                        }
                        return Column(
                          children: home.recentTxns.map((txn) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TransactionTile(txn: txn, onTap: () => Get.toNamed(AppRoutes.receipt, arguments: txn.transactionId)),
                          )).toList(),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showNotifications(BuildContext context, HomeController home) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Obx(() => home.notifications.isEmpty
                ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No notifications')))
                : Column(children: home.notifications.take(5).map((n) => ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.primary),
                    title: Text(n['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(n['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  )).toList())),
          ],
        ),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final _services = const [
    {'label': 'Data', 'icon': Icons.wifi, 'route': AppRoutes.buyData, 'color': Color(0xFF1A73E8)},
    {'label': 'Airtime', 'icon': Icons.phone_in_talk, 'route': AppRoutes.buyAirtime, 'color': Color(0xFF00BCD4)},
    {'label': 'Cable TV', 'icon': Icons.tv, 'route': AppRoutes.buyCable, 'color': Color(0xFF9C27B0)},
    {'label': 'Electricity', 'icon': Icons.flash_on, 'route': AppRoutes.buyElectricity, 'color': Color(0xFFFF9800)},
    {'label': 'Education', 'icon': Icons.school, 'route': AppRoutes.buyEducation, 'color': Color(0xFF4CAF50)},
    {'label': 'Fund Wallet', 'icon': Icons.account_balance_wallet, 'route': AppRoutes.fundWallet, 'color': Color(0xFF607D8B)},
  ];

  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
      itemCount: _services.length,
      itemBuilder: (_, i) {
        final s = _services[i];
        return GestureDetector(
          onTap: () => Get.toNamed(s['route'] as String),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: (s['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 24)),
              const SizedBox(height: 8),
              Text(s['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
        );
      },
    );
  }
}
