import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core/core_config.dart';
import 'package:lux/core/core_manager.dart';
import 'package:lux/tr.dart';
import 'package:lux/util/notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:yaml/yaml.dart';

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
      await Future.delayed(const Duration(seconds: 2));
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
      args: [launchFromStartupArg],
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

Locale convertLocale(String locale) {
  switch (locale) {
    case 'en-US':
      {
        return const Locale('en');
      }
    case 'zh-CN':
      {
        return const Locale('zh');
      }
    default:
      {
        var curLocale = Intl.getCurrentLocale();
        if (curLocale.startsWith('zh')) {
          return const Locale('zh');
        } else {
          return const Locale('en');
        }
      }
  }
}

Future<Locale> getLocale() async {
  var curLanguage = await readLanguage();
  return convertLocale(curLanguage);
}

typedef InitI10nLabel = ({
  String macOSElevateServiceInfo,
  String macOSNotElevatedMsg
});

Future<InitI10nLabel> getInitI10nLabel() async {
  var locale = await getLocale();

  if (locale == const Locale('zh')) {
    return (
      macOSElevateServiceInfo: "Lux 权限提升服务",
      macOSNotElevatedMsg: "核心没有以 root 身份运行"
    );
  }
  return (
    macOSElevateServiceInfo: "Lux elevation service",
    macOSNotElevatedMsg: "Lux_core is not run as root"
  );
}

Function compareVersion = (String a, String b) {
  var versionA = Version.parse(a);
  var versionB = Version.parse(b);
  return versionA.compareTo(versionB);
};

Future<void> checkForUpdate() async {
  try {
    final dio = Dio();
    var latestReleaseRes = await dio
        .get('https://api.github.com/repos/igoogolx/lux/releases/latest');
    if (latestReleaseRes.data.containsKey('tag_name') &&
        latestReleaseRes.data['tag_name'] is String) {
      var latestVersion = latestReleaseRes.data['tag_name'].replaceAll('v', '');
      var currentVersion = await getAppVersion();
      debugPrint(
          'latest version: $latestVersion, current version: $currentVersion');
      if (compareVersion(latestVersion, currentVersion) == 1) {
        notifier.show(tr().newVersionMessage, notifierPayloadNewRelease);
      }
    }
  } catch (e) {
    debugPrint('error checking for updates: $e');
  }
}

String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} M';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} G';
}

Future<String> getAppVersion() async {
  try {
    String pubspec = File(Paths.pubspec).readAsStringSync();
    final parsed = loadYaml(pubspec);
    if (parsed['version'] is String) {
      final version = parsed['version'] as String;
      return version;
    }
    throw "invalid version";
  } catch (e) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

void resetSystemProxy() {
  if (!Platform.isWindows) {
    return;
  }
  const keyPath =
      r'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  final key = Registry.openPath(
    RegistryHive.currentUser,
    path: keyPath,
    desiredAccessRights: AccessRights.writeOnly,
  );
  const dword = RegistryValue.int32('ProxyEnable', 0);
  key.createValue(dword);
  key.close();
}
