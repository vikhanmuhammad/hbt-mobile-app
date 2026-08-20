import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Product IDs harus persis sama dengan yang dibuat di Play Console
/// (Monetize > Products > Subscriptions).
const Set<String> proSubscriptionProductIds = {'pro_monthly', 'pro_yearly'};

/// `true` = verifikasi purchase ke Cloud Function `verifyPurchase` (yang
/// cross-check ke Play Developer API) — butuh Firebase project di plan
/// Blaze. `false` (sekarang) = trust hasil purchase dari Play Billing
/// langsung di client (lihat [LocalEntitlementService]), dipakai selama
/// project masih Spark. Flip ke `true` begitu sudah Blaze + functions
/// ter-deploy — tidak ada perubahan lain yang dibutuhkan, lihat
/// `entitlementServiceProvider` di community_providers.dart.
const bool kUseServerPurchaseVerification = false;

/// Wraps `in_app_purchase` — query produk, mulai pembelian, dan (tergantung
/// [kUseServerPurchaseVerification]) verifikasi tiap purchase ke server atau
/// trust client langsung. Status Pro yang dipakai UI datang dari
/// [EntitlementService] yang aktif ([IAPEntitlementService] atau
/// [LocalEntitlementService]), bukan dari state lokal di sini — kelas ini
/// murni actor untuk memicu & memverifikasi pembelian.
class PurchaseService {
  PurchaseService(this._iap, this._functions, {this.onLocalGrant});

  final InAppPurchase _iap;
  final FirebaseFunctions _functions;

  /// Dipanggil saat purchase sukses dan [kUseServerPurchaseVerification]
  /// false — biasanya `LocalEntitlementService.grant`.
  final void Function(String productId)? onLocalGrant;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _errorController = StreamController<String>.broadcast();

  /// Error pembelian (dibatalkan, gagal, error jaringan, dsb) untuk
  /// ditampilkan sebagai snackbar/toast oleh UI yang memicu `buy`.
  Stream<String> get purchaseErrors => _errorController.stream;

  void init() {
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) => _errorController.add(error.toString()),
    );
  }

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails(proSubscriptionProductIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PurchaseService: product IDs not found in store: ${response.notFoundIDs}');
    }
    return response.productDetails;
  }

  /// [uid] dikirim sebagai `applicationUserName` -> jadi obfuscated account
  /// id di Play Billing, dipakai Cloud Functions buat memetakan notifikasi
  /// RTDN kembali ke user Firestore yang benar (lihat functions/src/playBilling.ts).
  Future<void> buy(ProductDetails product, {required String uid}) {
    final purchaseParam = PurchaseParam(productDetails: product, applicationUserName: uid);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases({required String uid}) {
    return _iap.restorePurchases(applicationUserName: uid);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (kUseServerPurchaseVerification) {
            await _verify(purchase);
          } else {
            onLocalGrant?.call(purchase.productID);
          }
        case PurchaseStatus.error:
          _errorController.add(purchase.error?.message ?? 'Purchase failed.');
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verify(PurchaseDetails purchase) async {
    try {
      await _functions.httpsCallable('verifyPurchase').call<Map<String, dynamic>>({
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
      });
    } on FirebaseFunctionsException catch (e) {
      _errorController.add(e.message ?? 'Could not verify purchase.');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _errorController.close();
  }
}
