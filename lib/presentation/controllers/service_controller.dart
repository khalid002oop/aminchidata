import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/data_plan_model.dart';
import '../../routes/app_pages.dart';
import 'home_controller.dart';

class ServiceController extends GetxController {
  final isLoading       = false.obs;
  final networks        = <String>[].obs;
  final planTypes       = <String>[].obs;
  final dataPlans       = <DataPlanModel>[].obs;
  final cables          = <CableProviderModel>[].obs;
  final cablePlans      = <CablePlanModel>[].obs;
  final discos          = <DiscoModel>[].obs;
  final exams           = <ExamModel>[].obs;
  final validatedName   = ''.obs;

  final selectedNetwork  = ''.obs;
  final selectedType     = ''.obs;
  final selectedPlan     = Rx<DataPlanModel?>(null);
  final selectedCable    = Rx<CableProviderModel?>(null);
  final selectedCablePlan= Rx<CablePlanModel?>(null);
  final selectedDisco    = Rx<DiscoModel?>(null);
  final selectedExam     = Rx<ExamModel?>(null);
  final purchaseResult   = Rx<Map<String, dynamic>?>(null);

  void _showError(String msg) => Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));

  // ────── DATA ──────
  Future<void> loadNetworks() async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.dataPlans, query: {'action': 'get_networks'});
    isLoading.value = false;
    if (res.success) networks.value = List<String>.from(res.data['networks'] ?? []);
  }

  Future<void> loadPlanTypes(String network) async {
    selectedNetwork.value = network;
    selectedType.value    = '';
    selectedPlan.value    = null;
    planTypes.clear();
    dataPlans.clear();
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.dataPlans, query: {'action': 'get_types', 'network': network});
    isLoading.value = false;
    if (res.success) planTypes.value = List<String>.from(res.data['types'] ?? []);
  }

  Future<void> loadPlans(String network, String type) async {
    selectedType.value = type;
    selectedPlan.value = null;
    dataPlans.clear();
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.dataPlans, query: {'action': 'get_plans', 'network': network, 'type': type});
    isLoading.value = false;
    if (res.success) dataPlans.value = (res.data['plans'] as List? ?? []).map((e) => DataPlanModel.fromJson(e)).toList();
  }

  // ────── CABLE ──────
  Future<void> loadCables() async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.cable, query: {'action': 'get_cables'});
    isLoading.value = false;
    if (res.success) cables.value = (res.data['cables'] as List? ?? []).map((e) => CableProviderModel.fromJson(e)).toList();
  }

  Future<void> loadCablePlans(int cableId) async {
    cablePlans.clear();
    selectedCablePlan.value = null;
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.cable, query: {'action': 'get_plans', 'cable_id': cableId.toString()});
    isLoading.value = false;
    if (res.success) cablePlans.value = (res.data['plans'] as List? ?? []).map((e) => CablePlanModel.fromJson(e)).toList();
  }

  // ────── ELECTRICITY ──────
  Future<void> loadDiscos() async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.electricity);
    isLoading.value = false;
    if (res.success) discos.value = (res.data['discos'] as List? ?? []).map((e) => DiscoModel.fromJson(e)).toList();
  }

  // ────── EDUCATION ──────
  Future<void> loadExams() async {
    isLoading.value = true;
    final res = await ApiClient.get(ApiConstants.education);
    isLoading.value = false;
    if (res.success) exams.value = (res.data['exams'] as List? ?? []).map((e) => ExamModel.fromJson(e)).toList();
  }

  // ────── VALIDATE ──────
  Future<bool> validateIUC(int cableId, String smartCardNumber) async {
    validatedName.value = '';
    isLoading.value = true;
    final res = await ApiClient.post(ApiConstants.validate, {'action': 'validate_iuc', 'cable_id': cableId, 'smart_card_number': smartCardNumber});
    isLoading.value = false;
    if (res.success) { validatedName.value = res.data?['customer_name'] ?? 'Verified'; return true; }
    _showError(res.message);
    return false;
  }

  Future<bool> validateMeter(int discoId, String meterNumber, String meterType) async {
    validatedName.value = '';
    isLoading.value = true;
    final res = await ApiClient.post(ApiConstants.validate, {'action': 'validate_meter', 'disco_id': discoId, 'meter_number': meterNumber, 'meter_type': meterType});
    isLoading.value = false;
    if (res.success) { validatedName.value = res.data?['customer_name'] ?? 'Verified'; return true; }
    _showError(res.message);
    return false;
  }

  // ────── PURCHASE ──────
  Future<void> purchase(Map<String, dynamic> payload) async {
    isLoading.value = true;
    final res = await ApiClient.post(ApiConstants.purchase, payload);
    isLoading.value = false;
    if (res.success) {
      purchaseResult.value = res.data as Map<String, dynamic>;
      // Refresh wallet balance
      try { Get.find<HomeController>().refreshBalance(); } catch (_) {}
      Get.toNamed(AppRoutes.receipt, arguments: res.data['transaction_id']?.toString() ?? '');
    } else {
      _showError(res.message);
    }
  }
}
