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
