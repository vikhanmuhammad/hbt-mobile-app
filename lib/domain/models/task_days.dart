import 'dart:convert';

import '../language.dart';
import 'enums.dart';

/// Encode/decode the `taskDays` column (JSON array text in Drift) into a
/// `List<String>` of weekday keys (`mon`..`sun`) or `["all"]`.
class TaskDays {
  TaskDays._();

  static List<String> decode(String raw) {
    if (raw.isEmpty) return [allDaysKey];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // fall through to default
    }
    return [allDaysKey];
  }

  static String encode(List<String> days) => jsonEncode(days);

  static bool isEveryDay(List<String> days) =>
      days.isEmpty || days.contains(allDaysKey);

  static bool includesWeekday(List<String> days, int dateTimeWeekday) {
    if (isEveryDay(days)) return true;
    final key = weekdayKeys[dateTimeWeekday - 1];
    return days.contains(key);
  }

  static String summaryLabel(List<String> days, AppLang lang) {
    if (isEveryDay(days)) return lang == AppLang.id ? 'Setiap hari' : 'Every day';
    final ordered = weekdayKeys.where(days.contains).toList();
    return ordered.map((d) => weekdayLabel(d, lang)).join(', ');
  }
}
