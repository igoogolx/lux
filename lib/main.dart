import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/elevate.dart';
import 'package:lux/home.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/tray.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:window_manager/window_manager.dart';


var uuid = Uuid();

ProcessManager? process;
var baseUrl = '';
var urlStr = '';
var homeDir = '';

void exitApp() {
  process?.exit();
  exit(0);
}

void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await notifier.ensureInitialized();

  try {
    await windowManager.ensureInitialized();


    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final port = await findAvailablePort(8000, 9000);
    final Directory appDocumentsDir = await getApplicationSupportDirectory();
    final Version currentVersion = Version.parse(packageInfo.version);
    homeDir = path.join(appDocumentsDir.path, '${currentVersion.major}.0');
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
    process = ProcessManager(
        corePath, ['-home_dir=$homeDir', '-port=$port', '-secret=$secret']);
    await process?.run();
    process?.watchExit();
    baseUrl = 'http://localhost:$port';
    urlStr = '$baseUrl/?client_version=$currentVersion&token=$secret';
    final manager = CoreManager(baseUrl, process, secret);
    await manager.ping();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 650),
      center: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {});

    if (Platform.isWindows) {
      initSystemTray(exitApp, () {
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



