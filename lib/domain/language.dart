/// Bahasa tampilan aplikasi (setting global persisten, lihat
/// `appLanguageProvider` di `settings_providers.dart`) — dipakai oleh model
/// domain (`Habit`, `Category`) untuk memilih varian judul/goal-phrase yang
/// benar tanpa perlu import layer provider (menghindari circular import).
enum AppLang { en, id }
