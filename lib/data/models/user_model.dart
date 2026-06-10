class UserModel {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String? referralCode;
  final String createdAt;
  double walletBalance;
  int referralCount;
  double referralEarnings;
  VirtualAccount? virtualAccount;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.referralCode,
    required this.createdAt,
    this.walletBalance = 0,
    this.referralCount = 0,
    this.referralEarnings = 0,
    this.virtualAccount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final stats = json['stats'] ?? {};
    return UserModel(
      id:               user['id'] ?? 0,
      username:         user['username'] ?? '',
      email:            user['email'] ?? '',
      phone:            user['phone'] ?? '',
      referralCode:     user['referral_code'],
      createdAt:        user['created_at'] ?? '',
      walletBalance:    (json['wallet']?['balance'] ?? user['wallet_balance'] ?? 0).toDouble(),
      referralCount:    (stats['referral_count'] ?? json['referral_count'] ?? 0) as int,
      referralEarnings: ((stats['referral_earnings'] ?? json['referral_earnings'] ?? 0) as num).toDouble(),
      virtualAccount:   json['virtual_account'] != null
          ? VirtualAccount.fromJson(json['virtual_account'])
          : null,
    );
  }
}

class VirtualAccount {
  final String accountNumber;
  final String accountName;
  final String bankName;

  VirtualAccount({required this.accountNumber, required this.accountName, required this.bankName});

  factory VirtualAccount.fromJson(Map<String, dynamic> j) => VirtualAccount(
    accountNumber: j['account_number'] ?? '',
    accountName:   j['account_name'] ?? '',
    bankName:      j['bank_name'] ?? '',
  );
}
