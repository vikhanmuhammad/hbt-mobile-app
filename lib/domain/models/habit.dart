import '../format_utils.dart';
import '../language.dart';
import 'enums.dart';

class Habit {
  const Habit({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalValueWeekend,
    this.goalUnit = 'x',
    this.goalDirection = GoalDirection.atLeast,
    required this.taskDays,
    required this.timeRange,
    required this.reminderEnabled,
    this.reminderTime,
    this.reminderIntervalMinutes,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.sortOrder = 0,
    required this.createdAt,
    this.nameId,
    this.isCustom = true,
    this.templateKey,
    this.currency,
  });

  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? icon;
  final GoalPeriod goalPeriod;
  final int goalValue;

  /// Override [goalValue] khusus Sabtu-Minggu — hanya relevan untuk habit
  /// `daily` (diset lewat toggle "Custom per hari" di form). Null berarti
  /// nilai sama setiap hari (perilaku lama, tidak breaking).
  final int? goalValueWeekend;
  final String goalUnit;
  final GoalDirection goalDirection;
  final List<String> taskDays;
  final TimeRange timeRange;
  final bool reminderEnabled;
  final String? reminderTime;

  /// Minutes between repeats starting at [reminderTime] — null means a
  /// single reminder at that time (the original behavior). No end time:
  /// repeats until the end of the day.
  final int? reminderIntervalMinutes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  /// Terjemahan Indonesia dari [name] — null kalau belum diisi (habit
  /// lama/custom), fallback ke [name] lewat [displayName].
  final String? nameId;

  /// False kalau title berasal dari template bawaan yang sudah
  /// dikonfirmasi (lihat backfill di `HabitRepository`) — title bawaan
  /// dikunci dari edit. Default true (bisa diedit) supaya habit yang gagal
  /// dicocokkan ke template tidak tiba-tiba terkunci tanpa alasan jelas.
  final bool isCustom;

  /// Key stabil ke entri habit di `habit_templates.json`. Null untuk habit
  /// custom buatan user.
  final String? templateKey;

  /// Kode mata uang (IDR/USD/SGD/MYR/EUR) untuk habit Budget Tracker —
  /// label/prefix tampilan saja, tidak mengubah format angka. Null untuk
  /// habit non-finance atau habit Budget Tracker lama sebelum kolom ini
  /// ada (diperlakukan sebagai 'IDR' lewat [currencyPrefix]).
  final String? currency;

  /// Prefix tampilan untuk field budget, mis. "Rp " untuk IDR/null, "USD "
  /// untuk lainnya — label saja, bukan format angka per-currency.
  String get currencyPrefix =>
      (currency == null || currency == 'IDR') ? 'Rp ' : '${currency!} ';

  String displayName(AppLang lang) =>
      lang == AppLang.id ? (nameId ?? name) : name;

  bool get isRupiah => goalUnit == 'rupiah';

  String _formatGoalValue(int value) => isRupiah
      ? formatCurrency(value, currencyPrefix)
      : (goalUnit == 'x' ? '${value}x' : '$value $goalUnit');

  /// Mis. "8 gelas", "1x", atau "Rp 50.000" untuk satuan rupiah, persis
  /// format `unitLabel` di prototipe. Diberi prefix "Maks." untuk habit
  /// `atMost` (mis. batas pengeluaran) supaya arah target langsung jelas
  /// dibaca.
  String get goalValueLabel {
    final value = _formatGoalValue(goalValue);
    return goalDirection == GoalDirection.atMost ? 'Maks. $value' : value;
  }

  String goalLabel(AppLang lang) => '$goalValueLabel • ${goalPeriod.label(lang)}';

  /// Nilai efektif [goalValue] pada [date] — Sabtu/Minggu pakai
  /// [goalValueWeekend] kalau diset, selain itu (atau kalau null) tetap
  /// [goalValue]. Satu sumber kebenaran dipakai semua consumer (progress,
  /// achievement, agregasi Finance) supaya "hari apa dibandingkan ke target
  /// mana" konsisten di seluruh app.
  int goalValueFor(DateTime date) {
    final weekend = goalValueWeekend;
    if (weekend == null) return goalValue;
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    return isWeekend ? weekend : goalValue;
  }

  /// Label goal untuk hari [date] spesifik (mis. dipakai quick-progress-sheet
  /// yang mengedit progress 1 hari tertentu) — sudah resolve weekday/weekend
  /// lewat [goalValueFor], jadi cuma 1 nilai yang ditampilkan.
  String goalValueLabelForDate(DateTime date) {
    final value = _formatGoalValue(goalValueFor(date));
    return goalDirection == GoalDirection.atMost ? 'Maks. $value' : value;
  }

  /// Konversi goal habit ini (disimpan pada goalPeriod aslinya — Daily,
  /// Weekly, atau Monthly) menjadi rate per-hari untuk [date] — aturan
  /// tunggal yang dipakai Finance/Budget Tracker supaya budget yang
  /// diinput di satu periode ikut menyesuaikan otomatis ke periode lain,
  /// bukan diam sebagai angka mentah yang sama (feedback 6, slide 18-21):
  /// Monthly -> Daily = goalValue dibagi jumlah hari di bulan [date];
  /// Weekly -> Daily = goalValue dibagi 7; Daily sudah berupa rate harian
  /// (lewat [goalValueFor], termasuk override akhir pekan).
  double dailyRateFor(DateTime date) {
    switch (goalPeriod) {
      case GoalPeriod.daily:
        return goalValueFor(date).toDouble();
      case GoalPeriod.weekly:
        return goalValue / 7;
      case GoalPeriod.monthly:
        final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
        return goalValue / daysInMonth;
    }
  }

  /// Varian [goalValueLabel] yang menampilkan weekdays & weekend terpisah
  /// kalau [goalValueWeekend] diset (mis. "Maks. Rp50.000 (hari kerja) /
  /// Rp100.000 (akhir pekan)").
  String goalValueLabelFor(AppLang lang) {
    final weekend = goalValueWeekend;
    if (weekend == null) return goalValueLabel;
    final weekdayLabel = lang == AppLang.id ? 'hari kerja' : 'weekdays';
    final weekendLabel = lang == AppLang.id ? 'akhir pekan' : 'weekend';
    final prefix = goalDirection == GoalDirection.atMost ? 'Maks. ' : '';
    return '$prefix${_formatGoalValue(goalValue)} ($weekdayLabel) / '
        '${_formatGoalValue(weekend)} ($weekendLabel)';
  }

  /// Satu sumber kebenaran untuk "tercapai atau belum" — dipakai baik saat
  /// menyimpan progress (`HabitLogRepository.setProgress`) maupun di tempat
  /// lain yang perlu mengevaluasi ulang. `atLeast` (standar): tercapai kalau
  /// progress >= goalValue. `atMost` (mis. batas pengeluaran harian):
  /// tercapai kalau progress <= goalValue. [date] dipakai untuk resolve
  /// goalValue efektif lewat [goalValueFor] — null berarti pakai [goalValue]
  /// langsung (backward compatible untuk caller yang belum date-aware).
  /// [hasLog] tells whether [progressValue] actually came from a real log,
  /// as opposed to just defaulting to 0 because none exists yet. Only
  /// matters for `atMost` (mis. Budget Tracker): 0 spending trivially
  /// satisfies "at most limit", which wrongly marks it "achieved" before the
  /// user has ever touched it for this period (feedback 6, slide 10 & 11 —
  /// the same bug inflated the checklist checkmark AND the progress ring/
  /// dashboard, since both fed off this same unconditional comparison).
  /// `atLeast` is unaffected: 0 progress is already correctly "not achieved"
  /// whenever goal > 0.
  bool isAchieved(int progressValue, {DateTime? date, bool hasLog = true}) {
    if (goalDirection == GoalDirection.atMost && !hasLog) return false;
    final goal = date != null ? goalValueFor(date) : goalValue;
    return goalDirection == GoalDirection.atMost
        ? progressValue <= goal
        : progressValue >= goal;
  }

  /// Kontribusi [progressValue] terhadap goal, 0.0-1.0 — dipakai stats/
  /// Dashboard supaya habit yang belum tercapai (mis. 4 dari target 10)
  /// tetap tercatat sebagian, bukan cuma dihitung kalau sudah `isAchieved`
  /// penuh. Untuk `atMost` (batas maksimum) tetap biner: progres di bawah
  /// limit tidak punya "porsi" yang natural untuk dihitung parsial.
  double progressCredit(int progressValue, {DateTime? date, bool hasLog = true}) {
    final goal = date != null ? goalValueFor(date) : goalValue;
    if (goalDirection == GoalDirection.atMost || goal <= 0) {
      return isAchieved(progressValue, date: date, hasLog: hasLog) ? 1.0 : 0.0;
    }
    return (progressValue / goal).clamp(0.0, 1.0);
  }
}
