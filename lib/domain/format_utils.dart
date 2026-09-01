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

/// Same thousands-separator formatting as [formatRupiah], but with an
/// arbitrary currency [prefix] instead of hardcoded "Rp " — used for Budget
/// Tracker habits, whose selected currency (IDR/USD/SGD/MYR/EUR) is a
/// label/prefix only, not a real per-currency number format (no decimals,
/// no different grouping rules per currency). `formatRupiah` stays as-is,
/// equivalent to `formatCurrency(value, 'Rp ')`.
String formatCurrency(int value, String prefix) =>
    NumberFormat.currency(locale: 'id_ID', symbol: prefix, decimalDigits: 0).format(value);
