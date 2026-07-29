DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
