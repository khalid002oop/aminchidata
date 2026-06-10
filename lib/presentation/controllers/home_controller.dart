import 'dart:convert';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage.dart';
import '../../data/models/user_model.dart';
import '../../data/models/transaction_model.dart';

class HomeController extends GetxController {
  final isLoading       = true.obs;
  final user            = Rx<UserModel?>(null);
  final recentTxns      = <TransactionModel>[].obs;
  final notifications   = <Map<String, dynamic>>[].obs;
  final balanceVisible  = true.obs;

  double get walletBalance => user.value?.walletBalance ?? 0;
  int    get referralCount => user.value?.referralCount ?? 0;
  double get referralEarnings => user.value?.referralEarnings ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  void toggleBalanceVisibility() => balanceVisible.value = !balanceVisible.value;

  Future<void> loadDashboard() async {
    isLoading.value = true;
    await Future.wait([_loadProfile(), _loadRecentTxns(), _loadNotifications()]);
    isLoading.value = false;
  }

  Future<void> _loadProfile() async {
    final res = await ApiClient.get(ApiConstants.profile);
    if (res.success && res.data != null) {
      user.value = UserModel.fromJson(res.data as Map<String, dynamic>);
      await Storage.saveUserData(jsonEncode(res.data));
    }
  }

  Future<void> _loadRecentTxns() async {
    final res = await ApiClient.get(ApiConstants.history, query: {'limit': '5', 'page': '1'});
    if (res.success && res.data != null) {
      final list = (res.data['transactions'] as List?) ?? [];
      recentTxns.value = list.map((e) => TransactionModel.fromJson(e)).toList();
    }
  }

  Future<void> _loadNotifications() async {
    final res = await ApiClient.get(ApiConstants.notifications);
    if (res.success && res.data != null) {
      notifications.value = List<Map<String, dynamic>>.from(res.data['notifications'] ?? []);
    }
  }

  Future<void> refreshBalance() async {
    final res = await ApiClient.get(ApiConstants.profile);
    if (res.success && res.data != null) {
      user.value = UserModel.fromJson(res.data as Map<String, dynamic>);
    }
  }
}
