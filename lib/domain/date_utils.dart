DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> weekdayFullNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

const List<String> monthFullNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// Mis. "Kamis, 30 Juli 2026" — persis `dateLabelFmt` di prototipe
/// (Intl.DateTimeFormat id-ID weekday/day/month/year long).
String formatFullDate(DateTime date) =>
    '${weekdayFullNames[date.weekday - 1]}, ${date.day} ${monthFullNames[date.month - 1]} ${date.year}';
