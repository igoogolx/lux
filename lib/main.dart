import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_config.dart';
import 'package:lux/elevate.dart';
import 'package:lux/home.dart';
import 'package:lux/notifier.dart';
import 'package:lux/tr.dart';
import 'package:lux/utils.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  try {
    await windowManager.ensureInitialized();

    var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
    if (Platform.isMacOS && !kDebugMode) {
      var owner = await getFileOwner(corePath);
      if (owner != "root") {
        var code = await elevate(corePath, "Lux elevation service");
        if (code != 0) {
          notifier.show("App is not run as root");
          exitApp();
        }
      }
    }

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 650),
      center: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      windowManager.center();
      windowManager.show();
    });


    var isDarkMode = await readTheme() == ThemeType.dark;
    var theme = isDarkMode ? "dark" : "light";
    debugPrint("using theme: $theme");
    runApp(MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: isDarkMode ? Color(darkBackgroundColor) : Colors.white), //Dark mode of dashboard
        home: Home(theme),
        onGenerateTitle: (context) {
          initTr(context);
          return 'Lux';
        },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
      ],
    )
    );
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}


class LocaleModel extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void set(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}