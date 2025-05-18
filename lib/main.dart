import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lux/app.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_config.dart';
import 'package:lux/notifier.dart';
import 'package:lux/tr.dart';
import 'package:lux/utils.dart';
import 'package:window_manager/window_manager.dart';

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    notifier.show(error.toString());
    return true;
  };

  try {
    await windowManager.ensureInitialized();

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


