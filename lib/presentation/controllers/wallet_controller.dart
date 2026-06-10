import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/user_model.dart';
import 'home_controller.dart';

class WalletController extends GetxController {
  final isLoading      = false.obs;
  final virtualAccount = Rx<VirtualAccount?>(null);

  void _showError(String msg)   => Get.snackbar('Error',   msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
  void _showSuccess(String msg) => Get.snackbar('Success', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));

  Future<void> loadVirtualAccount() async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.virtualAccount);
    isLoading.value = false;
    if (res.success && res.data?['virtual_account'] != null) {
      virtualAccount.value = VirtualAccount.fromJson(res.data['virtual_account']);
    }
  }

  Future<void> generateVirtualAccount() async {
    isLoading.value = true;
    final res = await ApiClient.post(ApiConstants.virtualAccount, {});
    isLoading.value = false;
    if (res.success && res.data?['virtual_account'] != null) {
      virtualAccount.value = VirtualAccount.fromJson(res.data['virtual_account']);
      _showSuccess('Virtual account generated!');
    } else {
      _showError(res.message);
    }
  }

  Future<void> fundWallet(double amount) async {
    isLoading.value = true;
    final res = await ApiClient.post(ApiConstants.initPayment, {'amount': amount});
    isLoading.value = false;
    if (!res.success) { _showError(res.message); return; }

    final url = res.data['authorization_url'] as String;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // User returns to app; they tap "I've paid" button to verify
    } else {
      _showError('Could not open payment page. Please try again.');
    }
  }

  Future<void> verifyPayment(String reference) async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.verifyPayment, query: {'reference': reference});
    isLoading.value = false;
    if (res.success) {
      _showSuccess(res.message);
      try { Get.find<HomeController>().refreshBalance(); } catch (_) {}
    } else {
      _showError(res.message);
    }
  }
}
