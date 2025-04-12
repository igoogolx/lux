import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

BuildContext? buildContext;

void initTr(BuildContext trContext){
  buildContext = trContext;
}

AppLocalizations tr() {
  return AppLocalizations.of(buildContext!)!;
}