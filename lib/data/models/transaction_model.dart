class TransactionModel {
  final String transactionId;
  final String serviceType;
  final String description;
  final double amount;
  final String status;
  final String createdAt;
  final Map<String, dynamic> extra;

  TransactionModel({
    required this.transactionId,
    required this.serviceType,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.extra = const {},
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
    transactionId: j['transaction_id'] ?? '',
    serviceType:   j['service_type'] ?? '',
    description:   j['description'] ?? '',
    amount:        (j['amount'] ?? 0).toDouble(),
    status:        j['status'] ?? '',
    createdAt:     j['created_at'] ?? '',
    extra:         (j['extra'] as Map<String, dynamic>?) ?? {},
  );

  bool get isSuccess => status == 'SUCCESS';
  bool get isPending => status == 'PENDING';
  bool get isFailed  => status == 'FAILED';

  // Convenience alias for receipt screen
  String get id => transactionId;

  // Extra fields populated by receipt API
  String? get phone           => extra['phone'] as String?;
  String? get network         => extra['network'] as String?;
  String? get planName        => extra['plan_name'] as String?;
  String? get smartCardNumber => extra['smart_card_number'] as String?;
  String? get cable           => extra['cable'] as String?;
  String? get meterNumber     => extra['meter_number'] as String?;
  String? get disco           => extra['disco'] as String?;
  String? get meterType       => extra['meter_type'] as String?;
  String? get exam            => extra['exam'] as String?;
  int?    get quantity        => extra['quantity'] as int?;
  String? get token           => extra['token'] as String?;
  List<String>? get pins {
    final raw = extra['pins'];
    if (raw == null) return null;
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return null;
  }
}
