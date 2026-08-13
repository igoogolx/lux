import 'package:flutter/cupertino.dart';

import 'l10n/app_localizations.dart';

BuildContext? buildContext;

void initTr(BuildContext trContext){
  buildContext = trContext;
}

AppLocalizations tr() {
  return AppLocalizations.of(buildContext!)!;
}


class LocaleModel extends ChangeNotifier {
  Locale _locale= const Locale('zh');
  Locale? get locale => _locale;
  void set(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}