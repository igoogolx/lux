import 'package:flutter/material.dart';

class AppStateModel extends ChangeNotifier {
  late ThemeMode _theme;
  late Locale _locale;
  Locale get locale => _locale;
  ThemeMode get theme => _theme;

  AppStateModel(this._theme, this._locale);

  void updateTheme(ThemeMode newTheme) {
    _theme = newTheme;
    notifyListeners();
  }

  void updateLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}
