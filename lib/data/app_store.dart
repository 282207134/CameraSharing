import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Local demo state. Only card suffixes are persisted; no passwords or CVV.
class AppStore extends ChangeNotifier {
  AppStore({Future<void> Function(String)? save}) : _save = save;
  final Future<void> Function(String)? _save;
  bool signedIn = false, promoUsed = false;
  String name = 'Soumitro Sobuj', email = 'sobujdattabd@gmail.com';
  int balance = 7201, selectedCamera = 0, credit = 20;
  List<String> cards = ['1035', '5648'];
  List<Rental> rentals = [...sampleRentals];
  Camera? activeCamera;
  Camera get camera => cameras[selectedCamera];

  static Future<AppStore> load({String storageKey = 'camshare.v1'}) async {
    final prefs = SharedPreferencesAsync();
    final store = AppStore(save: (data) => prefs.setString(storageKey, data));
    final raw = await prefs.getString(storageKey);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        store.signedIn = json['signedIn'] as bool;
        store.name = json['name'] as String;
        store.email = json['email'] as String;
        store.balance = json['balance'] as int;
        store.cards = List<String>.from(json['cards'] as List);
        store.promoUsed = json['promoUsed'] as bool;
        store.rentals = (json['rentals'] as List)
            .map((e) => Rental.fromJson(e))
            .toList();
        final active = json['activeCamera'] as int?;
        if (active != null && active >= 0 && active < cameras.length) {
          store.activeCamera = cameras[active];
          store.selectedCamera = active;
        }
      } on FormatException {
        // Keep usable defaults if the saved demo data is damaged.
      } on TypeError {
        // A changed or incomplete schema falls back to the demo data.
      }
    }
    return store;
  }

  Future<void> _commit() async {
    await _save?.call(
      jsonEncode({
        'signedIn': signedIn,
        'name': name,
        'email': email,
        'balance': balance,
        'cards': cards,
        'promoUsed': promoUsed,
        'rentals': rentals.map((e) => e.toJson()).toList(),
        'activeCamera': activeCamera == null
            ? null
            : cameras.indexOf(activeCamera!),
      }),
    );
    notifyListeners();
  }

  Future<void> signIn(String address, {String? userName}) async {
    signedIn = true;
    email = address.trim();
    if (userName != null) name = userName.trim();
    await _commit();
  }

  void selectCamera(int index) {
    selectedCamera = index;
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newEmail) async {
    name = newName.trim();
    email = newEmail.trim();
    await _commit();
  }

  Future<void> addCard(String number) async {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final suffix = digits.substring(digits.length - 4);
    if (!cards.contains(suffix)) cards.add(suffix);
    await _commit();
  }

  Future<bool> applyPromo(String code) async {
    if (promoUsed || code.trim().toUpperCase() != 'CAMSHARE1578') return false;
    promoUsed = true;
    balance += 1000;
    await _commit();
    return true;
  }

  Future<void> topUp() async {
    balance += credit * 100;
    await _commit();
  }

  Future<bool> unlock(String code) async {
    if (!RegExp(r'^\d{4}$').hasMatch(code) ||
        activeCamera != null ||
        balance < 410) {
      return false;
    }
    activeCamera = camera;
    await _commit();
    return true;
  }

  Future<void> finishRental() async {
    final active = activeCamera;
    if (active == null) return;
    balance -= 410;
    rentals.insert(
      0,
      Rental(
        active.name,
        active.address,
        'Just now | Demo rental completed',
        410,
      ),
    );
    activeCamera = null;
    await _commit();
  }
}
