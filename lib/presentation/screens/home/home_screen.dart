import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          _HistoryTab(),
          _WalletTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xFFB0BEC5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DASHBOARD TAB ───────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Obx(() {
      if (home.isLoading.value && home.user.value == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: home.loadDashboard,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(home: home)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    const _ServicesGrid(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.history),
                          child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (home.recentTxns.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Column(children: [
                            Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.textSecondary.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            const Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ])),
                        );
                      }
                      return Column(
                        children: home.recentTxns.map((txn) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TransactionTile(txn: txn, onTap: () => Get.toNamed(AppRoutes.receipt, arguments: txn.transactionId)),
                        )).toList(),
                      );
                    }),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final HomeController home;
  const _Header({required this.home});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052CC), Color(0xFF0747A6)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          home.user.value?.username ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )),
                  ),
                  GestureDetector(
                    onTap: () => _showNotifications(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => _BalanceCard(
                balance: home.user.value?.walletBalance ?? 0,
                visible: home.balanceVisible.value,
                onToggle: home.toggleBalanceVisibility,
                accountNumber: home.user.value?.virtualAccount?.accountNumber,
                bankName: home.user.value?.virtualAccount?.bankName,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Obx(() => home.notifications.isEmpty
                ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary))))
                : Column(children: home.notifications.take(5).map((n) => ListTile(
                    leading: Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications, color: AppColors.primary, size: 20)),
                    title: Text(n['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(n['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  )).toList())),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final bool visible;
  final VoidCallback onToggle;
  final String? accountNumber;
  final String? bankName;

  const _BalanceCard({
    required this.balance, required this.visible,
    required this.onToggle, this.accountNumber, this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const Spacer(),
            GestureDetector(
              onTap: onToggle,
              child: Icon(visible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 20),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            visible ? '₦${balance.toStringAsFixed(2)}' : '₦  ••••••',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          if (accountNumber != null) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bankName ?? '', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(accountNumber!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              ])),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber!));
                  Get.snackbar('Copied', 'Account number copied to clipboard', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ]),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.fundWallet),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text('Fund Wallet', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.virtualAccount),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.account_balance_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('My Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  static const _services = [
    {'label': 'Data', 'icon': Icons.wifi_rounded, 'route': AppRoutes.buyData, 'color': Color(0xFF0052CC), 'bg': Color(0xFFEBF0FF)},
    {'label': 'Airtime', 'icon': Icons.phone_in_talk_rounded, 'route': AppRoutes.buyAirtime, 'color': Color(0xFF00875A), 'bg': Color(0xFFE3FCEF)},
    {'label': 'Cable TV', 'icon': Icons.tv_rounded, 'route': AppRoutes.buyCable, 'color': Color(0xFF6554C0), 'bg': Color(0xFFEAE6FF)},
    {'label': 'Electricity', 'icon': Icons.bolt_rounded, 'route': AppRoutes.buyElectricity, 'color': Color(0xFFFF8B00), 'bg': Color(0xFFFFF0B3)},
    {'label': 'Education', 'icon': Icons.school_rounded, 'route': AppRoutes.buyEducation, 'color': Color(0xFF00B8D9), 'bg': Color(0xFFE6FCFF)},
    {'label': 'Refer & Earn', 'icon': Icons.people_alt_rounded, 'route': AppRoutes.referrals, 'color': Color(0xFFDE350B), 'bg': Color(0xFFFFEBE5)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
      ),
      itemCount: _services.length,
      itemBuilder: (_, i) {
        final s = _services[i];
        return GestureDetector(
          onTap: () => Get.toNamed(s['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: s['bg'] as Color, borderRadius: BorderRadius.circular(14)),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(s['label'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ]),
          ),
        );
      },
    );
  }
}

// ─── HISTORY TAB ─────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final tx = Get.find<TransactionController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          Expanded(
            child: Obx(() {
              if (tx.isLoading.value && tx.transactions.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (tx.transactions.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                ]));
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => tx.loadHistory(reset: true),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tx.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => TransactionTile(
                    txn: tx.transactions[i],
                    onTap: () => Get.toNamed(AppRoutes.receipt, arguments: tx.transactions[i].transactionId),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── WALLET TAB ──────────────────────────────────────────────────────────────

class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('My Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            // Gradient wallet card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0052CC), Color(0xFF0747A6)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF0052CC).withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Spacer(),
                  GestureDetector(
                    onTap: home.toggleBalanceVisibility,
                    child: Icon(home.balanceVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 20),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  home.balanceVisible.value ? '₦${(home.user.value?.walletBalance ?? 0).toStringAsFixed(2)}' : '₦  ••••••',
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
                if (home.user.value?.virtualAccount != null) ...[
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(home.user.value!.virtualAccount!.bankName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(home.user.value!.virtualAccount!.accountNumber,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ])),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: home.user.value!.virtualAccount!.accountNumber));
                        Get.snackbar('Copied', 'Account number copied', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.fundWallet),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Fund Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.virtualAccount),
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('View Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

// ─── PROFILE TAB ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final auth = Get.find<AuthController>();
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0052CC), Color(0xFF0747A6)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
              child: Obx(() => Column(children: [
                Container(
                  width: 84, height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(
                      (home.user.value?.username ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(home.user.value?.username ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(home.user.value?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('Balance: ₦${(home.user.value?.walletBalance ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ])),
            ),
            // Menu card
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  _Tile(icon: Icons.person_outline_rounded, label: 'My Profile', color: AppColors.primary, onTap: () => Get.toNamed(AppRoutes.profile)),
                  _divider(),
                  _Tile(icon: Icons.lock_outline_rounded, label: 'Change PIN', color: const Color(0xFF6554C0), onTap: () => Get.toNamed(AppRoutes.changePin)),
                  _divider(),
                  _Tile(icon: Icons.people_alt_outlined, label: 'Refer & Earn', color: const Color(0xFF00875A), onTap: () => Get.toNamed(AppRoutes.referrals)),
                  _divider(),
                  _Tile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: const Color(0xFFDE350B),
                    onTap: () => Get.dialog(AlertDialog(
                      title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('Are you sure you want to logout?'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => auth.logout(),
                          child: const Text('Logout', style: TextStyle(color: Color(0xFFDE350B), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16);
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
    );
  }
}
