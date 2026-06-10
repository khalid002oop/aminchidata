class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? v, [String label = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{11}$').hasMatch(v.replaceAll(RegExp(r'[\s\-]'), ''))) {
      return 'Enter a valid 11-digit phone number';
    }
    return null;
  }

  static String? pin(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'PIN must be exactly 4 digits';
    return null;
  }

  static String? amount(String? v, {double min = 0}) {
    if (v == null || v.isEmpty) return 'Amount is required';
    final a = double.tryParse(v.replaceAll(',', ''));
    if (a == null) return 'Enter a valid amount';
    if (a < min) return 'Minimum amount is ₦${min.toStringAsFixed(0)}';
    return null;
  }
}
