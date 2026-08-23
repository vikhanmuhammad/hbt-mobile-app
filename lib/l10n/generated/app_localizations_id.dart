// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Daily Habits';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsNoName => 'Tanpa Nama';

  @override
  String get settingsProMember => 'Anggota Pro';

  @override
  String get settingsSectionSettings => 'Pengaturan';

  @override
  String get settingsHabitManager => 'Kelola Habit';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsDarkMode => 'Mode gelap';

  @override
  String get settingsSectionHealthCalendarSync =>
      'Sinkronisasi Kesehatan & Kalender';

  @override
  String get settingsSectionProAccess => 'Akses Pro';

  @override
  String get settingsSectionDefaultReminder => 'Pengingat Default';

  @override
  String get settingsSectionAbout => 'Tentang';

  @override
  String get settingsUsageTips => 'Tips Penggunaan';

  @override
  String get settingsFaqs => 'Tanya Jawab';

  @override
  String get settingsContactUs => 'Hubungi kami';

  @override
  String get settingsShare => 'Bagikan';

  @override
  String get settingsRestorePurchases => 'Pulihkan Pembelian';

  @override
  String get settingsDeleteAccount => 'Hapus Akun';

  @override
  String get settingsAboutBody =>
      'Berdasarkan riset Phillippa Lally dkk. (UCL): sebuah habit baru butuh rata-rata 66 hari pengulangan untuk menjadi otomatis. Fokus pada konsistensi, bukan kesempurnaan.\n\nSepenuhnya offline. Semua rekomendasi berasal dari data statis di aplikasi, tanpa akun atau sinkronisasi cloud.';

  @override
  String get settingsReplayOnboarding => 'Ulangi alur onboarding';

  @override
  String settingsNoEmailApp(String email) {
    return 'Aplikasi email tidak ditemukan — hubungi kami di $email';
  }

  @override
  String get settingsShareText =>
      'Saya sedang membangun kebiasaan baik dengan Daily Habits — yuk gabung!';

  @override
  String get settingsSignInFirstToRestore =>
      'Masuk akun dulu untuk memulihkan pembelian.';

  @override
  String get settingsRestoringPurchases => 'Memulihkan pembelian…';

  @override
  String get settingsDeleteAccountTitle => 'Hapus akun?';

  @override
  String get settingsDeleteAccountBody =>
      'Ini akan menghapus permanen akun Community Anda — keanggotaan grup, riwayat chat, dan hak akses Pro yang terkait. Data habit lokal di perangkat ini tidak terpengaruh. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get settingsAccountDeleted => 'Akun terhapus.';

  @override
  String settingsDeleteAccountFailed(String error) {
    return 'Gagal menghapus akun: $error';
  }

  @override
  String get settingsDeleteAllDataTitle => 'Hapus semua data?';

  @override
  String get settingsDeleteAllDataBody =>
      'Semua kategori, habit, dan riwayat progres akan dihapus permanen, lalu aplikasi kembali ke alur onboarding dari awal. Tindakan ini tidak bisa dibatalkan.';

  @override
  String get settingsDeleteAll => 'Hapus Semua';

  @override
  String get settingsProMode => 'Mode Pro';

  @override
  String settingsDefaultReminderTime(String time) {
    return 'Waktu pengingat default: $time';
  }

  @override
  String get homeDone => 'Selesai';

  @override
  String get homeToday => 'Hari Ini';

  @override
  String get homeMyHabits => 'Habit Saya';

  @override
  String get homeCommunity => 'Komunitas';

  @override
  String get homeDeleteHabitTitle => 'Hapus habit ini?';

  @override
  String homeDeleteHabitBody(String name) {
    return '\"$name\" beserta seluruh riwayat progresnya akan dihapus permanen dan tidak lagi dihitung di statistik Dashboard. Tindakan ini tidak bisa dibatalkan.';
  }

  @override
  String homeFailedToSaveProgress(String error) {
    return 'Gagal menyimpan progres: $error';
  }

  @override
  String get homeNoHabitsScheduledYet => 'Belum ada habit terjadwal';

  @override
  String get homeEmptyStateHint =>
      'Ketuk tombol Add Habit di kiri bawah untuk menambahkan habit pertama Anda hari ini.';

  @override
  String get commonByHabit => 'Per Habit';

  @override
  String get commonByCategory => 'Per Kategori';

  @override
  String get financeProFeatureTitle => 'Keuangan — Fitur Pro';

  @override
  String get financeProFeatureDescription =>
      'Lacak pengeluaran, tabungan, dan habit menabung dalam satu rangkuman bulanan. Upgrade ke Pro untuk membuka fitur ini.';

  @override
  String get financeProBenefit1 =>
      'Total pengeluaran & tabungan bulanan dari semua habit keuangan Anda';

  @override
  String get financeProBenefit2 =>
      'Grafik tren pengeluaran harian supaya pola terlihat lebih awal';

  @override
  String get financeProBenefit3 =>
      'Rincian per habit untuk melihat persis ke mana uang Anda pergi';

  @override
  String get financePeriodDaily => 'Harian';

  @override
  String get financePeriodWeekly => 'Mingguan';

  @override
  String get financePeriodMonthly => 'Bulanan';

  @override
  String financeFailedToLoad(String error) {
    return 'Gagal memuat rangkuman keuangan: $error';
  }

  @override
  String get financeNoFinanceHabitsYet => 'Belum ada habit keuangan';

  @override
  String get financeEmptyHint =>
      'Tambahkan habit bersatuan Rupiah (mis. batas pengeluaran harian di \"Menabung\") untuk mulai melihat rangkuman di sini.';

  @override
  String get financeTotalSpending => 'Total Pengeluaran';

  @override
  String financeOfBudget(String amount) {
    return 'dari anggaran $amount';
  }

  @override
  String get financeSaveMoneyGoal => 'Target Menabung';

  @override
  String get financeOverBudget => 'Melebihi Anggaran';

  @override
  String get financeTotalSaved => 'Total Tertabung';

  @override
  String get financeTotalDeposited => 'Total Disetor';

  @override
  String get financeOnTrack => 'Sesuai Rencana';

  @override
  String get financeOverspending => 'Boros';

  @override
  String get financeDailySpendingTrend => 'Tren Pengeluaran Harian';

  @override
  String get financeNoDataYet => 'Belum ada data';

  @override
  String dashboardFailedToLoadCalendar(String error) {
    return 'Gagal memuat kalender: $error';
  }

  @override
  String dashboardFailedToLoadDashboard(String error) {
    return 'Gagal memuat dashboard: $error';
  }

  @override
  String get dashboardFilterHabit => 'Filter Habit';

  @override
  String get dashboardSwipeToSeeMore => 'Geser untuk lihat lainnya';

  @override
  String get dashboardAll => 'Semua';

  @override
  String get dashboardNoHabitsScheduledToday =>
      'Tidak ada habit terjadwal hari ini.';

  @override
  String dashboardFailedToUpdateProgress(String error) {
    return 'Gagal memperbarui progres: $error';
  }

  @override
  String dashboardDateToday(String date) {
    return '$date (Hari Ini)';
  }

  @override
  String get dashboardNoDataToShowYet => 'Belum ada data untuk ditampilkan';

  @override
  String get dashboardEmptyHint =>
      'Mulai centang habit hari ini supaya dashboard mulai terisi.';

  @override
  String dashboardDaysTracked(int count) {
    return '$count hari tercatat';
  }

  @override
  String get dashboardOverallAvgSuccessRate =>
      'Rata-rata tingkat keberhasilan keseluruhan';

  @override
  String get dashboardMonthlyTrend => 'Tren Bulanan';

  @override
  String get addHabitPickGoalPhrase => 'Pilih goal phrase untuk habit baru.';

  @override
  String addHabitFailedToLoadCategories(String error) {
    return 'Gagal memuat kategori: $error';
  }

  @override
  String get addHabitCreateNewGoal => 'Buat Goal Baru';

  @override
  String get addHabitFinanceProOnly =>
      'Kategori Keuangan (Menabung) khusus Pro. Upgrade ke Pro untuk mengelola habit keuangan & melihat rangkuman tabungan.';

  @override
  String addHabitFreeLimitMessage(int limit) {
    return 'Anda sudah mencapai batas $limit habit aktif untuk pengguna Free. Upgrade ke Pro untuk menambah habit tanpa batas.';
  }

  @override
  String get addHabitNoRecommendations =>
      'Belum ada rekomendasi untuk kategori ini.';

  @override
  String get addHabitAdd => 'Tambah';

  @override
  String get addHabitAddCustomHabit => '+ Tambah Habit Custom';

  @override
  String get addHabitAdded => 'Habit ditambahkan';

  @override
  String addHabitFailedToAdd(String error) {
    return 'Gagal menambahkan habit: $error';
  }

  @override
  String get addHabitTitlePickGoalPhrase => 'Pilih Goal Phrase';

  @override
  String get addHabitTitleAddHabit => 'Tambah Habit';

  @override
  String get addHabitTitleEditHabit => 'Edit Habit';

  @override
  String get addHabitTitleHabitForm => 'Form Habit';

  @override
  String get addHabitTitleNewGoal => 'Goal Baru';

  @override
  String get addHabitFieldHabitName => 'Nama Habit';

  @override
  String get addHabitHintNameEn => 'Name (English)';

  @override
  String get addHabitHintNameId => 'Nama (Indonesia)';

  @override
  String get addHabitLockedNameNotice =>
      'Bawaan aplikasi — nama tidak bisa diubah.';

  @override
  String get addHabitFieldIcon => 'Ikon';

  @override
  String get addHabitChangeIcon => 'Ganti ikon';

  @override
  String get addHabitFieldGoalPhrase => 'Goal Phrase';

  @override
  String get addHabitFieldGoalPeriod => 'Periode Target';

  @override
  String get addHabitFieldGoalValue => 'Nilai Target';

  @override
  String get addHabitFieldUnit => 'Satuan';

  @override
  String get addHabitUnitHintCustom => 'mis. halaman buku';

  @override
  String get addHabitFieldTargetDirection => 'Arah Target';

  @override
  String get addHabitFieldTaskDays => 'Hari Aktif';

  @override
  String get addHabitEveryDay => 'Setiap hari';

  @override
  String get addHabitFieldTimeRange => 'Rentang Waktu';

  @override
  String get addHabitReminder => 'Pengingat';

  @override
  String get addHabitFieldStartDate => 'Tanggal Mulai';

  @override
  String get addHabitFieldEndDate => 'Tanggal Selesai';

  @override
  String get addHabitSetDate => 'Atur tanggal';

  @override
  String get addHabitNoLimit => 'Tanpa batas';

  @override
  String get addHabitNoTimeLimit => 'Tanpa batas waktu';

  @override
  String get addHabitSaveChanges => 'Simpan Perubahan';

  @override
  String get addHabitSaveHabit => 'Simpan Habit';

  @override
  String get addHabitNameRequired =>
      'Nama habit (Inggris & Indonesia) wajib diisi';

  @override
  String get addHabitPickGoalPhraseFirst => 'Pilih goal phrase dulu';

  @override
  String get addHabitPickAtLeastOneDay => 'Pilih minimal 1 hari aktif';

  @override
  String get addHabitUpdated => 'Habit diperbarui';

  @override
  String addHabitFailedToSave(String error) {
    return 'Gagal menyimpan habit: $error';
  }

  @override
  String get addHabitFieldGoalPhraseName => 'Nama Goal Phrase';

  @override
  String get addHabitHintCatNameEn => 'Name (English), mis. Hobby';

  @override
  String get addHabitHintCatNameId => 'Nama (Indonesia), mis. Hobi';

  @override
  String get addHabitFieldColor => 'Warna';

  @override
  String get addHabitCreateGoal => 'Buat Goal';

  @override
  String get addHabitCatNameRequired =>
      'Nama goal phrase (Inggris & Indonesia) wajib diisi';

  @override
  String addHabitFailedToCreateCategory(String error) {
    return 'Gagal membuat kategori: $error';
  }

  @override
  String get addHabitCommunityLockedNotice =>
      'Habit ini tertaut ke grup Community, jadi target dan jadwalnya terkunci supaya sama dengan semua orang yang melacaknya. Lepas tautan dari tab Habits grup dulu untuk mengubahnya. Pengaturan Pengingat tetap bisa Anda ubah.';

  @override
  String get unitNoUnit => 'Tanpa satuan';

  @override
  String get unitMinute => 'Menit';

  @override
  String get unitHour => 'Jam';

  @override
  String get unitStep => 'Langkah';

  @override
  String get unitGlass => 'Gelas';

  @override
  String get unitPage => 'Halaman';

  @override
  String get unitTime => 'Kali';

  @override
  String get unitKilometer => 'Kilometer';

  @override
  String get unitRupiah => 'Rupiah';

  @override
  String get unitCustom => 'Custom...';

  @override
  String get communityProFeatureTitle => 'Community — Fitur Pro';

  @override
  String get communityProFeatureDescription =>
      'Buat/gabung grup habit dengan teman, saling bersaing lewat leaderboard, dan chat secara real-time. Upgrade ke Pro untuk membuka fitur ini.';

  @override
  String get communityProBenefit1 =>
      'Buat atau gabung grup habit tanpa batas bersama teman dan keluarga';

  @override
  String get communityProBenefit2 =>
      'Bersaing di leaderboard real-time supaya tetap termotivasi bersama';

  @override
  String get communityProBenefit3 =>
      'Chat grup untuk saling menyemangati dan menjaga komitmen';

  @override
  String get communityTitle => 'Community';

  @override
  String get communityCreateGroup => '+ Buat Grup';

  @override
  String get communityJoinViaCode => 'Gabung via Kode';

  @override
  String communityMembersCount(int count) {
    return '$count anggota';
  }

  @override
  String get communitySignInTitle => 'Masuk untuk Melanjutkan';

  @override
  String get communitySignInBody =>
      'Community membutuhkan akun supaya progres Anda bisa dibagikan ke grup.';

  @override
  String get communitySignInWithGoogle => 'Masuk dengan Google';

  @override
  String communityFailedToSignIn(String error) {
    return 'Gagal masuk: $error';
  }

  @override
  String get communityLogOut => 'Keluar';

  @override
  String communityFailedToLoadGroups(String error) {
    return 'Gagal memuat grup: $error';
  }

  @override
  String get communityNoGroupsYet =>
      'Belum ada grup. Buat grup baru atau gabung dengan kode undangan dari teman.';

  @override
  String get communityLogOutTitle => 'Keluar dari Community?';

  @override
  String get communityLogOutBody =>
      'Anda perlu masuk lagi untuk melihat atau menyinkronkan grup Anda. Data habit lokal Anda tidak terpengaruh.';

  @override
  String get communityLogOutConfirm => 'Keluar';

  @override
  String get createGroupTitle => 'Buat Grup';

  @override
  String get createGroupNameLabel => 'Nama Grup';

  @override
  String get createGroupNameHint => 'mis. Morning Run Squad';

  @override
  String createGroupFailed(String error) {
    return 'Gagal membuat grup: $error';
  }

  @override
  String get joinGroupTitle => 'Gabung Grup';

  @override
  String get joinGroupInviteCodeLabel => 'Kode Undangan';

  @override
  String get joinGroupInviteCodeHint => 'mis. A1B2C3D4';

  @override
  String get joinGroupAskMember =>
      'Minta kode undangan dari anggota grup yang sudah ada.';

  @override
  String get joinGroupInviteCodeNotFound => 'Kode undangan tidak ditemukan';

  @override
  String get joinGroupAlreadyMember => 'Anda sudah menjadi anggota grup ini';

  @override
  String joinGroupFailed(String error) {
    return 'Gagal bergabung: $error';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonAdd => 'Tambah';

  @override
  String get commonRemove => 'Hapus';

  @override
  String get groupNotAvailable => 'Grup ini sudah tidak tersedia.';

  @override
  String groupFailedToLoad(String error) {
    return 'Gagal memuat grup: $error';
  }

  @override
  String groupInviteCodeCopied(String code) {
    return 'Kode undangan \"$code\" disalin';
  }

  @override
  String get groupPromoteAdminFirstTitle => 'Jadikan admin lain dulu';

  @override
  String get groupPromoteAdminFirstBody =>
      'Anda satu-satunya admin di grup ini. Jadikan anggota lain admin dulu sebelum keluar, atau hapus grup ini saja.';

  @override
  String get groupLeaveOnlyMemberBody =>
      'Anda satu-satunya anggota — keluar berarti Anda perlu kode undangan untuk bergabung lagi nanti. Hapus grup saja jika ingin menghilangkannya untuk selamanya.';

  @override
  String groupLeaveNeedInviteBody(String name) {
    return 'Anda perlu kode undangan baru untuk bergabung lagi ke \"$name\" nanti.';
  }

  @override
  String get groupLeaveTitle => 'Keluar dari grup?';

  @override
  String get groupLeaveConfirm => 'Keluar';

  @override
  String groupLeftMessage(String name) {
    return 'Anda keluar dari \"$name\".';
  }

  @override
  String groupFailedToLeave(String error) {
    return 'Gagal keluar dari grup: $error';
  }

  @override
  String get groupDeleteTitle => 'Hapus grup?';

  @override
  String groupDeleteBody(String name) {
    return 'Ini akan menghapus permanen \"$name\", Group Habit-nya, dan kode undangannya untuk semua orang di dalamnya. Tindakan ini tidak bisa dibatalkan.';
  }

  @override
  String groupDeletedMessage(String name) {
    return '\"$name\" telah dihapus.';
  }

  @override
  String groupFailedToDelete(String error) {
    return 'Gagal menghapus grup: $error';
  }

  @override
  String get groupCopyInviteCode => 'Salin kode undangan';

  @override
  String get groupLeaveGroup => 'Keluar Grup';

  @override
  String get groupDeleteGroup => 'Hapus Grup';

  @override
  String get groupTabHabits => 'Habits';

  @override
  String get groupTabLeaderboard => 'Leaderboard';

  @override
  String get groupTabChat => 'Chat';

  @override
  String get groupTabMembers => 'Anggota';

  @override
  String groupFailedToLoadGeneric(String error) {
    return 'Gagal memuat: $error';
  }

  @override
  String get groupNoHabitsYetBody =>
      'Anda belum punya habit — tambahkan dulu dari Home, lalu kembali ke sini untuk mengaktifkannya bersama grup.';

  @override
  String get groupYourHabits => 'Habit Anda';

  @override
  String get groupCommunityHabits => 'Habit Komunitas';

  @override
  String get groupLinked => 'Tertaut';

  @override
  String get groupAlreadyTrackedViaOther =>
      'Sudah dilacak di grup ini lewat habit Anda yang lain';

  @override
  String get groupMatchesExisting =>
      'Cocok dengan habit komunitas yang sudah ada';

  @override
  String get groupLinkAction => 'Tautkan';

  @override
  String get groupPublishAction => 'Publikasikan';

  @override
  String groupFailedToLink(String error) {
    return 'Gagal menautkan: $error';
  }

  @override
  String get groupRemoveFromCommunity => 'Hapus dari komunitas';

  @override
  String get groupReconnectBefore =>
      'Pernah Anda lacak sebelumnya — sambungkan lagi untuk melanjutkan';

  @override
  String get groupReconnectAction => 'Sambungkan Lagi';

  @override
  String get groupAddToMyHabits => 'Tambah ke Habit Saya';

  @override
  String groupLinkedTo(String name) {
    return 'Tertaut ke \"$name\"';
  }

  @override
  String get groupUnlink => 'Lepas Tautan';

  @override
  String groupFailedToUnlink(String error) {
    return 'Gagal melepas tautan: $error';
  }

  @override
  String get groupNoLeaderboardYetBody =>
      'Belum ada habit. Buka tab Habits dan publikasikan salah satu habit Anda untuk memulai leaderboard pertama.';

  @override
  String get leaderboardStreak => 'Streak';

  @override
  String get leaderboardProgress => 'Progress';

  @override
  String leaderboardFailedToLoad(String error) {
    return 'Gagal memuat leaderboard: $error';
  }

  @override
  String get leaderboardNoProgressYet => 'Belum ada progres tercatat.';

  @override
  String get leaderboardDaysUnit => 'hari';

  @override
  String leaderboardStreakLabel(int count) {
    return 'streak $count hari';
  }

  @override
  String leaderboardTotalLabel(String count, String unit) {
    return 'total $count $unit';
  }

  @override
  String get leaderboardYouSuffix => ' (Anda)';

  @override
  String get leaderboardJustNow => 'baru saja';

  @override
  String leaderboardMinutesAgo(int count) {
    return '${count}m lalu';
  }

  @override
  String leaderboardHoursAgo(int count) {
    return '${count}j lalu';
  }

  @override
  String leaderboardDaysAgo(int count) {
    return '${count}h lalu';
  }

  @override
  String leaderboardUpdatedLabel(String label, String time) {
    return '$label • Diperbarui $time';
  }

  @override
  String get groupNoGoalPhraseAvailable => 'Belum ada goal phrase tersedia';

  @override
  String get groupAddToHabitsTitle => 'Tambahkan ke habit Anda?';

  @override
  String groupAddToHabitsBody(String name, String target, String period) {
    return '\"$name\" ($target · $period) akan ditambahkan ke daftar habit Anda, dilacak persis seperti yang dipublikasikan di grup ini.';
  }

  @override
  String groupAddedRestored(String name, int count) {
    return '\"$name\" ditambahkan — $count hari riwayat dipulihkan';
  }

  @override
  String groupLinkedExistingHabit(String name) {
    return 'Habit \"$name\" Anda yang sudah ada telah ditautkan';
  }

  @override
  String groupAddedPlain(String name) {
    return '\"$name\" ditambahkan ke habit Anda';
  }

  @override
  String groupAddedRestoreFailed(String name, String error) {
    return '\"$name\" ditambahkan, tapi gagal memulihkan riwayat: $error';
  }

  @override
  String groupFailedToAddHabit(String error) {
    return 'Gagal menambahkan habit: $error';
  }

  @override
  String get groupRemoveFromCommunityTitle => 'Hapus dari komunitas?';

  @override
  String groupRemoveFromCommunityBody(String name) {
    return '\"$name\" dan leaderboard-nya akan dihapus untuk semua orang di grup. Habit dan riwayat progres lokal masing-masing tidak terpengaruh — tindakan ini tidak bisa dibatalkan.';
  }

  @override
  String groupFailedToRemove(String error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String chatFailedToSend(String error) {
    return 'Gagal mengirim pesan: $error';
  }

  @override
  String chatFailedToLoad(String error) {
    return 'Gagal memuat chat: $error';
  }

  @override
  String get chatNoMessagesYet => 'Belum ada pesan. Mulai percakapan!';

  @override
  String get chatWriteMessageHint => 'Tulis pesan...';

  @override
  String get membersInviteCodeLabel => 'Kode Undangan';

  @override
  String get membersMakeAdmin => 'Jadikan Admin';

  @override
  String get membersRemoveAdmin => 'Cabut Admin';

  @override
  String get membersRemove => 'Hapus';

  @override
  String get faqTitle => 'Tanya Jawab';

  @override
  String get faqQ1 => 'Kenapa aplikasi ini sepenuhnya offline?';

  @override
  String get faqA1 =>
      'Supaya data habit harian Anda tetap privat dan bisa dipakai kapan saja tanpa perlu koneksi internet. Tanpa akun, tanpa server, tanpa pelacakan.';

  @override
  String get faqQ2 => 'Bagaimana data saya disimpan dan apakah aman?';

  @override
  String get faqA2 =>
      'Semua data (kategori, habit, riwayat progres, profil) disimpan di database lokal pada perangkat Anda sendiri — tidak pernah dikirim ke mana pun.';

  @override
  String get faqQ3 => 'Bagaimana kalau saya ganti HP? Apakah data ikut pindah?';

  @override
  String get faqA3 =>
      'Karena tidak ada sinkronisasi cloud, data tidak berpindah otomatis. Gunakan fitur Export Data di Settings (segera hadir) untuk membuat cadangan manual sebelum ganti perangkat, lalu Import Data di HP baru.';

  @override
  String get faqQ4 => 'Apakah saya perlu masuk atau daftar akun?';

  @override
  String get faqA4 =>
      'Tidak. Aplikasi ini sama sekali tidak punya sistem akun — buka dan langsung pakai.';

  @override
  String get usageTipsTitle => 'Tips Penggunaan';

  @override
  String get usageTip1Title => 'Gunakan Pengingat';

  @override
  String get usageTip1Body =>
      'Saat menambah atau mengedit habit, aktifkan toggle Reminder dan atur waktunya. Aplikasi akan mengirim notifikasi lokal pada waktu itu di hari-hari aktif habit tersebut.';

  @override
  String get usageTip2Title => 'Isi Progres yang Terlewat';

  @override
  String get usageTip2Body =>
      'Dari tab Dashboard, ketuk tanggal lalu di kalender untuk melihat detail habit hari itu. Anda masih bisa menandai/mengubah progres untuk hari-hari sebelumnya dari sana.';

  @override
  String get usageTip3Title => 'Ganti Tema';

  @override
  String get usageTip3Body =>
      'Buka Settings > Personalize untuk memilih salah satu dari 5 palet warna. Perubahan langsung berlaku di seluruh aplikasi.';

  @override
  String get usageTip4Title => 'Gunakan Mode Edit';

  @override
  String get usageTip4Body =>
      'Ketuk tombol pensil di kanan bawah Home untuk masuk Mode Edit — dari sana Anda bisa mengurutkan ulang (seret), mengedit, atau menonaktifkan habit. Ketuk tombol centang atau \"Selesai\" untuk keluar.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileNameEmpty => 'Nama tidak boleh kosong';

  @override
  String get profileSaved => 'Profil tersimpan';

  @override
  String get profileChangePhoto => 'Ganti foto';

  @override
  String get profilePhotoNotAvailable =>
      'Foto profil belum tersedia di versi ini';

  @override
  String get profileNameLabel => 'Nama';

  @override
  String get profileNameHint => 'Nama Anda';

  @override
  String get profileAgeLabel => 'Usia';

  @override
  String get profileAgeHint => 'mis. 25';

  @override
  String get profileSaving => 'Menyimpan...';

  @override
  String get profileSave => 'Simpan';

  @override
  String get personalizeTitle => 'Personalize';

  @override
  String get personalizeDescription =>
      'Pilih tema warna yang paling Anda suka. Warna ini dipakai untuk tombol, cincin progres, dan aksen di seluruh aplikasi.';

  @override
  String get healthSyncStepsLabel => 'Sinkronkan langkah dari aplikasi Health';

  @override
  String get healthSyncCalendarLabel => 'Sinkronkan pengingat ke Kalender';

  @override
  String get healthSyncAlarmLabel => 'Sinkronkan pengingat ke Alarm HP';

  @override
  String healthSyncDeniedMessage(String feature) {
    return '$feature ditolak atau tidak tersedia di perangkat ini.';
  }

  @override
  String get healthSyncFeatureHealth => 'Akses Health';

  @override
  String get healthSyncFeatureCalendar => 'Akses Kalender';

  @override
  String get iconPickerChooseIcon => 'Pilih Ikon';

  @override
  String get iconPickerSearchHint => 'Cari ikon...';

  @override
  String get iconPickerNoIconsFound => 'Ikon tidak ditemukan';

  @override
  String get proFeatureUpgradeButton => 'Upgrade ke Pro';

  @override
  String proFeatureSignInFailed(String error) {
    return 'Gagal masuk: $error';
  }

  @override
  String get proFeatureCouldNotLoadPlans =>
      'Gagal memuat paket langganan. Coba lagi nanti.';

  @override
  String get proFeatureNoPlansAvailable =>
      'Belum ada paket langganan yang tersedia saat ini.';

  @override
  String get proFeatureChooseYourPlan => 'Pilih paket Anda';

  @override
  String get proFeatureTitle => 'Fitur Pro';

  @override
  String get quickProgressOrEnterManually => 'atau masukkan manual';

  @override
  String quickProgressTarget(String label) {
    return 'Target: $label';
  }

  @override
  String get quickProgressMarkAchieved => 'Tandai Tercapai';

  @override
  String get commonSave => 'Simpan';

  @override
  String get timerLabel => 'TIMER';

  @override
  String get timerPause => 'Jeda';

  @override
  String get timerResume => 'Lanjutkan';

  @override
  String get timerStart => 'Mulai';

  @override
  String get financeTitle => 'Keuangan';

  @override
  String get onboardingFinanceProFeature =>
      'Pelacakan keuangan adalah fitur Pro';

  @override
  String get onboardingCancelHabit => 'Batalkan habit ini';

  @override
  String get navHome => 'Home';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCommunity => 'Community';

  @override
  String get navFinance => 'Keuangan';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get addHabitCustomizeBeforeAdding => 'Sesuaikan sebelum menambahkan';

  @override
  String addHabitAddSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambah $count Habit',
    );
    return '$_temp0';
  }

  @override
  String addHabitAddedMultiple(int count) {
    return '$count habit ditambahkan';
  }
}
