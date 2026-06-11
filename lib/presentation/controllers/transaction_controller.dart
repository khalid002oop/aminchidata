import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/transaction_model.dart';

class TransactionController extends GetxController {
  final isLoading    = false.obs;
  final transactions = <TransactionModel>[].obs;
  final receipt      = Rx<TransactionModel?>(null);
  final currentPage  = 1.obs;
  final totalPages   = 1.obs;
  final hasMore      = true.obs;
  final filterStatus = 'all'.obs;
  final filterType   = 'all'.obs;

  Future<void> loadHistory({bool reset = false}) async {
    if (reset) { currentPage.value = 1; transactions.clear(); hasMore.value = true; }
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;
    final query = <String, String>{
      'page': currentPage.value.toString(),
      'limit': '20',
    };
    if (filterStatus.value != 'all') query['status'] = filterStatus.value;
    if (filterType.value != 'all') query['service_type'] = filterType.value;

    final res = await ApiClient.get(ApiConstants.history, query: query);
    isLoading.value = false;
    if (res.success && res.data != null) {
      final list = (res.data['transactions'] as List? ?? []).map((e) => TransactionModel.fromJson(e)).toList();
      transactions.addAll(list);
      final pagination = (res.data['pagination'] as Map<String, dynamic>?) ?? {};
      totalPages.value = (pagination['total_pages'] ?? 1) as int;
      hasMore.value    = currentPage.value < totalPages.value;
      currentPage.value++;
    }
  }

  Future<void> loadMore() => loadHistory();

  void clearFilters() {
    filterStatus.value = 'all';
    filterType.value   = 'all';
  }

  Future<void> loadReceipt(String tid) async {
    receipt.value   = null;
    isLoading.value = true;
    // Retry up to 3 times with a short gap to handle commit timing on slow connections
    for (int attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(seconds: 2));
      final res = await ApiClient.get(ApiConstants.receipt, query: {'tid': tid});
      if (res.success && res.data != null) {
        receipt.value   = TransactionModel.fromJson(res.data['transaction'] ?? res.data);
        isLoading.value = false;
        return;
      }
    }
    isLoading.value = false;
  }

  // Silent refresh used by the receipt screen polling loop
  Future<void> refreshReceipt(String tid) async {
    final res = await ApiClient.get(ApiConstants.receipt, query: {'tid': tid});
    if (res.success && res.data != null) {
      receipt.value = TransactionModel.fromJson(res.data['transaction'] ?? res.data);
    }
  }
}
