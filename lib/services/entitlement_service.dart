import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Abstraksi status Pro — seluruh fitur Community (paywall, entry point
/// navigasi, dsb) manggil interface ini, tidak peduli dari mana sumbernya.
/// update_v2.md §1.1.
abstract class EntitlementService {
  bool get isPro;
  Stream<bool> get isProChanges;
}

/// Implementasi development: toggle manual (mis. dari Settings), tidak
/// connect ke Play Billing/StoreKit apapun. Integrasi billing sungguhan
/// ditunda ke mendekati rilis — nanti tinggal swap ke `IAPEntitlementService`
/// via provider, screen Community tidak perlu berubah sama sekali.
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
