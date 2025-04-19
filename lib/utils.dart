import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/core_config.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/notifier.dart';
import 'package:lux/tr.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import 'package:intl/intl.dart';

Future<String> getHomeDir() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final Directory appDocumentsDir = await getApplicationSupportDirectory();
  final Version currentVersion = Version.parse(packageInfo.version);
  return path.join(appDocumentsDir.path, '${currentVersion.major}.0');
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  if (map is Map<String, dynamic>) {
    return map;
  }
  return {};
}

void exitApp() async {
  exit(0);
}

Future<void> setAutoConnect(CoreManager? coreManager) async {
  var isAutoConnect = await readAutoConnect();
  if (isAutoConnect) {
    try {
      await Future.delayed(const Duration(seconds: 1));
      await coreManager?.start();
      notifier.show(tr().connectOnOpenMsg);
    } catch (e) {
      String? msg = e.toString();
      if (e is DioException) {
        msg = e.message;
      }
      notifier.show(tr().connectOnOpenErrMsg(msg.toString()));
    }
  }
}

Future<void> setAutoLaunch(CoreManager? coreManager) async {
  try {
    var isAutoLaunch = await readAutoLaunch();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
    var isEnabled = await launchAtStartup.isEnabled();
    if (isAutoLaunch && !isEnabled) {
      await launchAtStartup.enable();
      return;
    }
    if (isEnabled && !isAutoLaunch) {
      await launchAtStartup.disable();
    }
  } catch (e) {
    notifier.show(tr().setAutoLaunchErrMsg(e));
  }
}

Future<Locale> getLocale() async {
  var curLanguage = await readLanguage();
  switch (curLanguage) {
    case 'system':
      {
        var curLocale = Intl.getCurrentLocale();
        if (curLocale.startsWith('zh')) {
          return const Locale('zh');
        } else {
          return const Locale('en');
        }
      }
    case 'en-US':
      {
        return const Locale('en');
      }
    case 'zh-CN':
      {
        return const Locale('zh');
      }
  }

  return const Locale('en');
}

typedef InitI10nLabel = ({String macOSElevateServiceInfo,String macOSNotElevatedMsg} );

Future<InitI10nLabel> getInitI10nLabel() async {
  var locale = await getLocale();

  if(locale==const Locale('zh')){
    return (
      macOSElevateServiceInfo: "Lux 权限提升服务",
      macOSNotElevatedMsg: "核心没有以 root 身份运行"
    );}
  return (
    macOSElevateServiceInfo: "Lux elevation service",
    macOSNotElevatedMsg: "Lux_core is not run as root"
  );
}
