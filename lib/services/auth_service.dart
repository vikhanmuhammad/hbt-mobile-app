import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wrapper Firebase Auth + Google Sign-In, khusus dipakai fitur Community —
/// dipicu saat user pertama kali masuk Community, bukan wajib untuk Free
/// tier (update_v2.md §9). Sign in with Apple menyusul setelah setup
/// capability Apple Developer beres.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  /// Melempar [GoogleSignInException] kalau user membatalkan alur sign-in —
  /// caller (UI) yang menangani supaya bisa tampilkan pesan sesuai konteks.
  Future<User?> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final authorization = await account.authorizationClient
        .authorizationForScopes(<String>['email']);
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization?.accessToken,
    );
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google Sign-In mungkin belum pernah diinisialisasi (mis. user login
      // lewat metode lain) — abaikan.
    }
  }

  /// Menghapus akun Firebase Auth yang sedang login — dibutuhkan Play Store
  /// account-deletion policy karena app ini mengizinkan pembuatan akun
  /// (Google Sign-In). [beforeDelete] jalan dulu selagi user masih
  /// ter-autentikasi (buat cleanup data terkait, mis. keluar dari
  /// grup/hapus dokumen Firestore) — Firestore rules butuh `request.auth`
  /// yang masih valid, jadi urutan ini penting.
  ///
  /// Firebase mewajibkan sesi "baru" untuk hapus akun; kalau sesi sudah
  /// lama, re-auth sekali lewat Google Sign-In lalu retry.
  Future<void> deleteAccount({required Future<void> Function() beforeDelete}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await beforeDelete();
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;
      await signInWithGoogle();
      await _firebaseAuth.currentUser?.delete();
    }
  }
}
