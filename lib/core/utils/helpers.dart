import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) =>
      '₦${NumberFormat('#,##0.00', 'en_US').format(amount)}';

  static String formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatShortDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  static String networkLogo(String network) {
    switch (network.toUpperCase()) {
      case 'MTN':      return 'MTN';
      case 'GLO':      return 'GLO';
      case 'AIRTEL':   return 'AIRTEL';
      case '9MOBILE':  return '9MOBILE';
      default:         return network;
    }
  }

  static String serviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'data':        return '📶';
      case 'airtime':     return '📞';
      case 'cable':       return '📺';
      case 'electricity': return '⚡';
      case 'education':   return '🎓';
      default:            return '💳';
    }
  }
}
