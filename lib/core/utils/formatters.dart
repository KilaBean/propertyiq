import 'package:intl/intl.dart';

final _decimal = NumberFormat.decimalPattern();
final _date = DateFormat.yMMMd();

/// "NGN 250,000" — currency code prefix + grouped amount. Kept simple for MVP;
/// per-locale currency symbols can come later.
String formatMoney(num amount, String currency) =>
    '$currency ${_decimal.format(amount)}';

/// "Jun 28, 2026"
String formatDate(DateTime date) => _date.format(date);

/// "just now" / "5m ago" / "3h ago" / "2d ago" / falls back to a date.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return _date.format(date);
}
