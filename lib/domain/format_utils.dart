import 'package:intl/intl.dart';

final _rupiahFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Formats a rupiah value with Indonesian-style thousands separators, e.g.
/// `50000` -> `"Rp 50.000"`. Used everywhere progress/target is shown for
/// habits with the `rupiah` unit (e.g. a "cut spending" habit).
String formatRupiah(int value) => _rupiahFormat.format(value);

/// Whether amounts in this currency carry cents — every Budget Tracker
/// currency except IDR (USD/SGD/MYR/EUR). Accepts a currency code ("SGD")
/// or a display prefix ("SGD ", "Rp "); null/empty means IDR.
///
/// Amounts are stored as integers in the currency's smallest unit: whole
/// rupiah for IDR, cents for the others — so SGD 5,50 is stored as 550
/// (feedback 8, slide 8).
bool currencyHasDecimals(String? currencyOrPrefix) {
  final code = (currencyOrPrefix ?? '').trim();
  return code.isNotEmpty && code != 'Rp' && code != 'IDR';
}

/// Stored units per whole currency unit — 100 for cent-based currencies, 1
/// for IDR. See [currencyHasDecimals].
int currencyMinorFactor(String? currencyOrPrefix) => currencyHasDecimals(currencyOrPrefix) ? 100 : 1;

/// Formats a stored amount (see [currencyHasDecimals]) with Indonesian-style
/// separators and the currency [prefix] — e.g. `50000` with "Rp " ->
/// "Rp 50.000", `550` with "SGD " -> "SGD 5,50".
String formatCurrency(int value, String prefix) {
  final decimals = currencyHasDecimals(prefix);
  return NumberFormat.currency(locale: 'id_ID', symbol: prefix, decimalDigits: decimals ? 2 : 0)
      .format(decimals ? value / 100 : value);
}

/// The same amount without the prefix, as an amount text field shows it —
/// trailing ",00" dropped so a whole amount reads "50" rather than "50,00".
/// Empty for 0.
String formatAmountInput(int value, String? currencyOrPrefix) {
  if (value == 0) return '';
  if (!currencyHasDecimals(currencyOrPrefix)) return NumberFormat.decimalPattern('id_ID').format(value);
  final text = NumberFormat('#,##0.00', 'id_ID').format(value / 100);
  return text.endsWith(',00') ? text.substring(0, text.length - 3) : text;
}
