import 'package:flutter/material.dart';

class AppStateModel extends ChangeNotifier {
  late ThemeMode _theme;
  late Locale _locale;
  String _selectedProxyId = "";
  bool _isStarted = false;

  Locale get locale => _locale;
  ThemeMode get theme => _theme;
  String get selectedProxyId => _selectedProxyId;
  bool get isStarted => _isStarted;

  AppStateModel(this._theme, this._locale);

  void updateTheme(ThemeMode newTheme) {
    _theme = newTheme;
    notifyListeners();
  }

  void updateLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  void updateIsStarted(bool newIsStarted) {
    if (newIsStarted == _isStarted) {
      return;
    }
    _isStarted = newIsStarted;
    notifyListeners();
  }

  void updateSelectedProxyId(String newSelectedProxyId) {
    if (newSelectedProxyId == _selectedProxyId) {
      return;
    }
    _selectedProxyId = newSelectedProxyId;
    notifyListeners();
  }
}
