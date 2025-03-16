import 'dart:convert';
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/core_config.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';

Future<String> getHomeDir() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final Directory appDocumentsDir = await getApplicationSupportDirectory();
  final Version currentVersion = Version.parse(packageInfo.version);
  return path.join(appDocumentsDir.path, '${currentVersion.major}.0');
}


Future<Map<String,dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  if(map is Map<String,dynamic>){
    return map;
  }
  return {};
}

void exitApp() async {
  exit(0);
}


void setAutoConnect(CoreManager? coreManager) async {
  var isAutoConnect = await readAutoConnect();
  if (isAutoConnect) {
    try {
      await Future.delayed(const Duration(seconds: 1));
      await coreManager?.start();
      notifier.show("Connect on open");
    } catch (e) {
      notifier.show("Fail to connect on open: $e");
    }
  }
}

void setAutoLaunch(CoreManager? coreManager) async {
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
}
