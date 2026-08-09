DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const List<String> weekdayFullNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const List<String> monthFullNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// E.g. "Thursday, 30 July 2026" — matches `dateLabelFmt` in the prototype
/// (Intl.DateTimeFormat en-US weekday/day/month/year long).
String formatFullDate(DateTime date) =>
    '${weekdayFullNames[date.weekday - 1]}, ${date.day} ${monthFullNames[date.month - 1]} ${date.year}';
