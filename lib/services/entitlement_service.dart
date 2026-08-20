import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraksi status Pro — seluruh fitur Community (paywall, entry point
/// navigasi, dsb) manggil interface ini, tidak peduli dari mana sumbernya.
/// update_v2.md §1.1.
abstract class EntitlementService {
  bool get isPro;
  Stream<bool> get isProChanges;
}

/// Implementasi development: toggle manual (mis. dari Settings), tidak
/// connect ke Play Billing/StoreKit apapun. Cuma dipakai lewat
/// `_DebugProToggleTile` yang di-gate `kDebugMode` — di release yang jadi
/// source of truth adalah [IAPEntitlementService].
class MockEntitlementService implements EntitlementService {
  MockEntitlementService(this._prefs);

  static const _key = 'debug_is_pro';

  final SharedPreferences _prefs;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get isPro => _prefs.getBool(_key) ?? false;

  @override
  Stream<bool> get isProChanges => _controller.stream;

  Future<void> setPro(bool value) async {
    await _prefs.setBool(_key, value);
    _controller.add(value);
  }

  void dispose() => _controller.close();
}

/// Status Pro sungguhan, di-drive oleh dokumen Firestore `users/{uid}` —
/// field `isPro` di situ HANYA ditulis oleh Cloud Functions (`verifyPurchase`,
/// `onPlayRTDN`) setelah verifikasi ke Google Play Developer API, tidak
/// pernah oleh client (lihat firestore.rules). Jadi status Pro tidak bisa
/// dipalsukan dengan cuma nulis Firestore dari app.
///
/// Mengikuti perubahan uid (`authStateChanges`) supaya otomatis switch
/// listener saat user login/logout/ganti akun.
class IAPEntitlementService implements EntitlementService {
  IAPEntitlementService(this._firestore, Stream<String?> uidChanges) {
    _uidSubscription = uidChanges.listen(_onUidChanged);
  }

  final FirebaseFirestore _firestore;
  final _controller = StreamController<bool>.broadcast();

  StreamSubscription<String?>? _uidSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSubscription;
  bool _isPro = false;

  @override
  bool get isPro => _isPro;

  @override
  Stream<bool> get isProChanges => _controller.stream;

  void _onUidChanged(String? uid) {
    _docSubscription?.cancel();
    if (uid == null) {
      _setIsPro(false);
      return;
    }
    _docSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) => _setIsPro(snapshot.data()?['isPro'] as bool? ?? false));
  }

  void _setIsPro(bool value) {
    if (value == _isPro) return;
    _isPro = value;
    _controller.add(value);
  }

  void dispose() {
    _uidSubscription?.cancel();
    _docSubscription?.cancel();
    _controller.close();
  }
}

/// Interim entitlement source while the Firebase project is still on the
/// Spark plan (Cloud Functions — `verifyPurchase`/`onPlayRTDN` — need Blaze
/// to deploy). Trusts the purchase result `in_app_purchase` reports directly
/// from Play Billing instead of a server round-trip: `PurchaseService` calls
/// [grant] right after a `purchased`/`restored` event when
/// `kUseServerPurchaseVerification` is false.
///
/// Known gap vs. [IAPEntitlementService]: no visibility into renewals or
/// cancellations that happen while the app isn't open (that's what RTDN is
/// for), and status doesn't survive a reinstall until the user taps "Restore
/// Purchases". Once Blaze is active, flip `kUseServerPurchaseVerification`
/// to true in purchase_service.dart — [entitlementServiceProvider] then
/// switches to [IAPEntitlementService] with no other code changes needed.
class LocalEntitlementService implements EntitlementService {
  LocalEntitlementService(this._prefs);

  static const _key = 'local_is_pro';

  final SharedPreferences _prefs;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get isPro => _prefs.getBool(_key) ?? false;

  @override
  Stream<bool> get isProChanges => _controller.stream;

  Future<void> grant(String productId) async {
    await _prefs.setBool(_key, true);
    _controller.add(true);
  }

  void dispose() => _controller.close();
}
