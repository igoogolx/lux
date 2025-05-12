import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lux/app.dart';
import 'package:lux/checksum.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_config.dart';
import 'package:lux/elevate.dart';
import 'package:lux/notifier.dart';
import 'package:lux/tr.dart';
import 'package:lux/utils.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  try {
    await windowManager.ensureInitialized();
    var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
    verifyCoreBinary(corePath);
    if (Platform.isMacOS && !kDebugMode) {
      var owner = await getFileOwner(corePath);
      if (owner != "root") {
        var i10nLabel = await getInitI10nLabel();
        var code = await elevate(corePath, i10nLabel.macOSElevateServiceInfo);
        if (code != 0) {
          notifier.show(i10nLabel.macOSElevateServiceInfo);
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
    var localeModel =  LocaleModel();
    var defaultLocaleValue = await getLocale();
    localeModel.set(defaultLocaleValue);
    runApp(App(theme, isDarkMode ? Color(darkBackgroundColor) : Colors.white,localeModel));
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}


