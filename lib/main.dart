import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_config.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/elevate.dart';
import 'package:lux/home.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/tray.dart';
import 'package:lux/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:window_manager/window_manager.dart';
import 'package:url_launcher/url_launcher.dart';

var uuid = Uuid();

CoreManager? coreManager;
var baseUrl = '';
var urlStr = '';
var homeDir = '';

void exitApp() async {
  await coreManager?.exitCore();
  exit(0);
}

void openDashboard() async {
  final Uri url = Uri.parse(urlStr);
  launchUrl(url);
}

void setAutoConnect() async {
  var isAutoConnect = await readAutoConnect();
  if(isAutoConnect){
    try {
      await Future.delayed(const Duration(seconds: 1));
      await coreManager?.start();
  notifier.show("Connect on open");
  }catch(e){
  notifier.show("Fail to connect on open: $e");
  }
}
}

void setAutoLaunch() async {
  var isAutoLaunch = await readAutoLaunch();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );
  var isEnabled = await launchAtStartup.isEnabled();
  if(isAutoLaunch && !isEnabled){
    await launchAtStartup.enable();
    return;
  }
  if(isEnabled && !isAutoLaunch){
    await launchAtStartup.disable();
  }
}

void initClient() {
  setAutoConnect();
  setAutoLaunch();
}

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  try {
    await windowManager.ensureInitialized();


    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final port = await findAvailablePort(8000, 9000);
    final Version currentVersion = Version.parse(packageInfo.version);
    homeDir = await getHomeDir();
    var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
    if (Platform.isMacOS) {
      var owner = await getFileOwner(corePath);
      if (owner != "root") {
        var code = await elevate(corePath, "Lux elevation service");
        if (code != 0) {
          notifier.show("App is not run as root");
          exitApp();
        }
      }
    }
    var secret = uuid.v4();
    final process = ProcessManager(
        corePath, ['-home_dir=$homeDir', '-port=$port', '-secret=$secret']);
    await process.run();
    process.watchExit();
    baseUrl = 'http://localhost:$port';
    urlStr = '$baseUrl/?client_version=$currentVersion&token=$secret';
    coreManager = CoreManager(baseUrl, process, secret);
    await coreManager?.ping();


    initClient();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 650),
      center: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {});

    if (Platform.isWindows) {
      initSystemTray(openDashboard,exitApp, () {
        windowManager.show();
        windowManager.focus();
      });
    }

    runApp(MaterialApp(home: Home(homeDir,baseUrl,urlStr)));
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}



