import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/transaction_controller.dart';
import '../../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final TransactionController _tx;
  final _scrollCtrl = ScrollController();

  final _types = ['all', 'data', 'airtime', 'cable', 'electricity', 'education', 'wallet_funding'];
  final _statuses = ['all', 'SUCCESS', 'PENDING', 'FAILED'];

  @override
  void initState() {
    super.initState();
    _tx = Get.find<TransactionController>();
    _tx.loadHistory(reset: true);
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        _tx.loadMore();
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilter),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (_tx.isLoading.value && _tx.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_tx.transactions.isEmpty) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No transactions yet', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ]));
        }
        return RefreshIndicator(
          onRefresh: () async => _tx.loadHistory(reset: true),
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _tx.transactions.length + (_tx.hasMore.value ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _tx.transactions.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
              }
              return TransactionTile(txn: _tx.transactions[i], onTap: () => Get.toNamed('/receipt', arguments: _tx.transactions[i].transactionId));
            },
          ),
        );
      }),
    );
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Service Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => Wrap(spacing: 8, runSpacing: 8, children: _types.map((t) {
              final selected = _tx.filterType.value == t;
              return ChoiceChip(label: Text(t == 'all' ? 'All' : t.replaceAll('_', ' ').capitalizeFirst!),
                selected: selected, onSelected: (_) => _tx.filterType.value = t,
                selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary));
            }).toList())),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => Wrap(spacing: 8, runSpacing: 8, children: _statuses.map((s) {
              final selected = _tx.filterStatus.value == s;
              final color = s == 'SUCCESS' ? AppColors.success : s == 'FAILED' ? AppColors.error : s == 'PENDING' ? AppColors.warning : AppColors.primary;
              return ChoiceChip(label: Text(s == 'all' ? 'All' : s),
                selected: selected, onSelected: (_) => _tx.filterStatus.value = s,
                selectedColor: color, labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary));
            }).toList())),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () { _tx.clearFilters(); Navigator.pop(ctx); }, child: const Text('Clear'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () { _tx.loadHistory(reset: true); Navigator.pop(ctx); }, child: const Text('Apply'))),
            ]),
          ]),
        ),
      ),
    );
  }
}
