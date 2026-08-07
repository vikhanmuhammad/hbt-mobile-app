// Awalnya digenerate oleh FlutterFire CLI, sekarang dimodifikasi supaya
// nilai konfigurasi dibaca dari `.env` (lewat `flutter_dotenv`) alih-alih
// literal string di source — jadi file ini tetap boleh ada di repo tanpa
// membocorkan API key/App ID project Firebase yang sesungguhnya. Pastikan
// `dotenv.load()` sudah dipanggil (lihat main.dart) sebelum
// `DefaultFirebaseOptions.currentPlatform` diakses.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await dotenv.load(fileName: '.env');
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static String _env(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Env var "$key" kosong/tidak ada — cek isi .env (lihat .env.example) '
        'dan pastikan dotenv.load() sudah dipanggil sebelum Firebase.initializeApp().',
      );
    }
    return value;
  }

  static String get _projectId => _env('FIREBASE_PROJECT_ID');
  static String get _messagingSenderId => _env('FIREBASE_MESSAGING_SENDER_ID');
  static String get _storageBucket => _env('FIREBASE_STORAGE_BUCKET');

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _env('FIREBASE_WEB_API_KEY'),
        appId: _env('FIREBASE_WEB_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _env('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: _storageBucket,
        measurementId: _env('FIREBASE_WEB_MEASUREMENT_ID'),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _env('FIREBASE_ANDROID_API_KEY'),
        appId: _env('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: _env('FIREBASE_IOS_API_KEY'),
        appId: _env('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _env('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: _env('FIREBASE_IOS_API_KEY'),
        appId: _env('FIREBASE_IOS_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _env('FIREBASE_IOS_BUNDLE_ID'),
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: _env('FIREBASE_WINDOWS_API_KEY'),
        appId: _env('FIREBASE_WINDOWS_APP_ID'),
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _env('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: _storageBucket,
        measurementId: _env('FIREBASE_WINDOWS_MEASUREMENT_ID'),
      );
}
