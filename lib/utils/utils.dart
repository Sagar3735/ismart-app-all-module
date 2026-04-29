import 'package:intl/intl.dart';

class AppUtils {
  // Format date
  static String formatDate(String? dateStr, {String format = 'short'}) {
    if (dateStr == null) return '—';
    final date = DateTime.parse(dateStr);
    switch (format) {
      case 'long':
        return DateFormat('EEEE, dd MMM yyyy').format(date);
      case 'day':
        return DateFormat('EEE, dd MMM').format(date);
      case 'monthYear':
        return DateFormat('MMMM yyyy').format(date);
      default:
        return DateFormat('dd MMM yyyy').format(date);
    }
  }

  // Working days between two dates (excludes weekends)
  static int calcWorkingDays(DateTime from, DateTime to) {
    int count = 0;
    DateTime cur = from;
    while (!cur.isAfter(to)) {
      if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
        count++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return count;
  }

  // Format currency in INR
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Get initials from name
  static String getInitials(String name) {
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  // Relative time label
  static String relativeTime(String dateStr) {
    final diff = DateTime.now().difference(DateTime.parse(dateStr));
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago';
  }

  // Validate leave form
  static Map<String, String?> validateLeaveForm({
    required String? leaveType,
    required DateTime? fromDate,
    required DateTime? toDate,
    required String reason,
    required String? managerId,
  }) {
    final errors = <String, String?>{};
    if (leaveType == null) errors['leaveType'] = 'Please select a leave type.';
    if (fromDate == null) errors['fromDate'] = 'From date is required.';
    if (toDate == null) errors['toDate'] = 'To date is required.';
    if (fromDate != null && toDate != null && toDate.isBefore(fromDate)) {
      errors['toDate'] = 'To date must be after from date.';
    }
    if (reason.trim().length < 5) {
      errors['reason'] = 'Please provide a reason (at least 5 characters).';
    }
    if (reason.length > 200) {
      errors['reason'] = 'Reason must be under 200 characters.';
    }
    if (managerId == null) {
      errors['managerId'] = 'Please select a reporting manager.';
    }
    return errors;
  }
}
