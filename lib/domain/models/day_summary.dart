class DaySummary {
  const DaySummary({
    required this.date,
    required this.totalCount,
    required this.doneCount,
  });

  final DateTime date;
  final int totalCount;
  final int doneCount;

  double get ratio => totalCount == 0 ? 0 : doneCount / totalCount;

  bool get hasData => totalCount > 0;
}
