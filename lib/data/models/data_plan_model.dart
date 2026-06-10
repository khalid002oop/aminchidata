class DataPlanModel {
  final int planId;
  final double amount;
  final String size;
  final String validity;

  DataPlanModel({required this.planId, required this.amount, required this.size, required this.validity});

  factory DataPlanModel.fromJson(Map<String, dynamic> j) => DataPlanModel(
    planId:   j['plan_id'] ?? 0,
    amount:   (j['amount'] ?? 0).toDouble(),
    size:     j['size'] ?? '',
    validity: j['validity'] ?? '',
  );

  String get label => '$size — ₦${amount.toStringAsFixed(0)} (${validity})';
}

class CablePlanModel {
  final int cableplanId;
  final String planName;
  final double amount;

  CablePlanModel({required this.cableplanId, required this.planName, required this.amount});

  factory CablePlanModel.fromJson(Map<String, dynamic> j) => CablePlanModel(
    cableplanId: j['cableplan_id'] ?? 0,
    planName:    j['plan_name'] ?? '',
    amount:      (j['amount'] ?? 0).toDouble(),
  );
}

class DiscoModel {
  final int discoId;
  final String discoName;

  DiscoModel({required this.discoId, required this.discoName});

  factory DiscoModel.fromJson(Map<String, dynamic> j) =>
      DiscoModel(discoId: j['disco_id'] ?? 0, discoName: j['disco_name'] ?? '');
}

class ExamModel {
  final int examId;
  final String examName;
  final double amount;

  ExamModel({required this.examId, required this.examName, required this.amount});

  factory ExamModel.fromJson(Map<String, dynamic> j) =>
      ExamModel(examId: j['exam_id'] ?? 0, examName: j['exam_name'] ?? '', amount: (j['amount'] ?? 0).toDouble());
}

class CableProviderModel {
  final int cableId;
  final String cableName;

  CableProviderModel({required this.cableId, required this.cableName});

  factory CableProviderModel.fromJson(Map<String, dynamic> j) =>
      CableProviderModel(cableId: j['cable_id'] ?? 0, cableName: j['cable_name'] ?? '');
}
