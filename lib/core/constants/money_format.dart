/// Lightweight currency formatting for the UI layer. Deliberately
/// dependency-free (no `intl` package) - Closet only ever needs to render
/// USD amounts with exactly two decimal places.

/// e.g. "$68.00". A stray negative amount renders as "-$4.99" rather than
/// the confusing "$-4.99".
String formatPrice(double amount) {
  final isNegative = amount < 0;
  final formatted = amount.abs().toStringAsFixed(2);
  return isNegative ? '-\$$formatted' : '\$$formatted';
}
