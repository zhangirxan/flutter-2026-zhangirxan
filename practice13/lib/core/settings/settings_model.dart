import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  // initial values are read in main() before runApp, so the first frame is right
  // (this._dark is still passed as dark: from outside)
  SettingsModel(
    this._prefs, {
    required this._dark,
    this._city,
    this._avatarPath,
  });

  final SharedPreferencesAsync _prefs;

  bool _dark;
  String? _city;
  String? _avatarPath;

  bool get dark => _dark;
  String? get city => _city;
  String? get avatarPath => _avatarPath;

  // screen first, disk after: the switch must not wait for the write
  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    _city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  Future<void> setAvatar(String path) async {
    _avatarPath = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}
