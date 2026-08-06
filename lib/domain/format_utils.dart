import 'package:intl/intl.dart';

final _rupiahFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Format nilai rupiah dengan pemisah ribuan ala Indonesia, mis. `50000` ->
/// `"Rp 50.000"`. Dipakai di semua tempat yang menampilkan progress/target
/// untuk habit bersatuan `rupiah` (mis. habit "hemat pengeluaran").
String formatRupiah(int value) => _rupiahFormat.format(value);
