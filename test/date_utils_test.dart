import 'package:flutter_test/flutter_test.dart';
import 'package:habbit_tracker_app/domain/date_utils.dart';

void main() {
  test('dayIndex and dateFromDayIndex are exact inverses', () {
    var day = DateTime(1990, 1, 1);
    for (var i = 0; i < 20000; i++) {
      final back = dateFromDayIndex(dayIndex(day));
      expect(back, DateTime(day.year, day.month, day.day));
      day = DateTime(day.year, day.month, day.day + 1);
    }
  });

  test('consecutive days map to consecutive indexes', () {
    expect(dayIndex(DateTime(2026, 9, 2)) - dayIndex(DateTime(2026, 9, 1)), 1);
    expect(dayIndex(DateTime(2026, 9, 2, 23, 59)), dayIndex(DateTime(2026, 9, 2)));
    expect(dayIndex(DateTime(1970, 1, 1)), 0);
  });
}
