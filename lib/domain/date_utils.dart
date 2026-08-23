import 'language.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> weekdayFullNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const List<String> weekdayFullNamesId = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

const List<String> monthFullNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> monthFullNamesId = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const List<String> monthShortNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> monthShortNamesId = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String monthFullName(int month, AppLang lang) =>
    (lang == AppLang.id ? monthFullNamesId : monthFullNames)[month - 1];

String monthShortName(int month, AppLang lang) =>
    (lang == AppLang.id ? monthShortNamesId : monthShortNames)[month - 1];

String weekdayFullName(int weekday, AppLang lang) =>
    (lang == AppLang.id ? weekdayFullNamesId : weekdayFullNames)[weekday - 1];

/// E.g. "Thursday, 30 July 2026" — matches `dateLabelFmt` in the prototype
/// (Intl.DateTimeFormat en-US weekday/day/month/year long).
String formatFullDate(DateTime date, AppLang lang) =>
    '${weekdayFullName(date.weekday, lang)}, ${date.day} ${monthFullName(date.month, lang)} ${date.year}';
