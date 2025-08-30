import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lux/app.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_config.dart';
import 'package:lux/error.dart';
import 'package:lux/notifier.dart';
import 'package:lux/tr.dart';
import 'package:lux/utils.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final coreHttpError = CoreHttpError.fromJson(error.response?.data);
        if (coreHttpError.code == coreHttpErrorNotElevatedCode) {
          notifier.show(tr().notElevated);
        } else {
          notifier.show(coreHttpError.message);
        }
        return true;
      }
    }
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
      var isLaunchFromStartUp =
          Platform.isWindows && args.contains(launchFromStartupArg);
      if (!isLaunchFromStartUp) {
        windowManager.show();
      } else {
        notifier.show(tr().launchAtStartUpMessage);
      }
    });

    var isDarkMode = await readTheme() == ThemeType.dark;
    var theme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    var clientMode = await readClientMode();
    var defaultLocaleValue = await getLocale();
    runApp(App(theme, defaultLocaleValue, clientMode));
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}
