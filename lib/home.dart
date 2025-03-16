import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/dashboard.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/progress_indicator.dart';
import 'package:lux/tray.dart';
import 'package:lux/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}


void initClient(CoreManager? coreManager) {
  setAutoConnect(coreManager);
  setAutoLaunch(coreManager);
}

class _HomeState extends State<Home> with WindowListener {
  String baseUrl = "";
  String urlStr = "";
  String homeDir = "";
  bool isReady = false;
  bool hasError = false;

  void _init() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
    var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
    var curHomeDir = await getHomeDir();
    final port = await findAvailablePort(8000, 9000);
    var uuid = Uuid();
    var secret = uuid.v4();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Version currentVersion = Version.parse(packageInfo.version);
    final process = ProcessManager(
        corePath, ['-home_dir=$curHomeDir', '-port=$port', '-secret=$secret']);
    var curBaseUrl = 'http://localhost:$port';
    var curUrlStr = '$curBaseUrl/?client_version=$currentVersion&token=$secret';
    var coreManager = CoreManager(curBaseUrl, process, secret, () {
      setState(() {
        isReady = true;
      });
    }, () {
      setState(() {
        hasError = true;
      });
    });
    coreManager.run();

    setState(() {
      homeDir = curHomeDir;
      baseUrl = curBaseUrl;
      urlStr = curUrlStr;
    });

    if (Platform.isWindows) {
      initSystemTray(() async {
        final Uri url = Uri.parse(urlStr);
        launchUrl(url);
      }, () async {
        await coreManager.exitCore();
        exit(0);
      }, () {
        windowManager.show();
        windowManager.focus();
      });
    }

    initClient(coreManager);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void onWindowClose() async {
    if (Platform.isMacOS) {
      if (await windowManager.isFullScreen()) {
        await windowManager.setFullScreen(false);
        //FIXME: remove delay
        await Future.delayed(const Duration(seconds: 1));
        await windowManager.minimize();
      } else {
        await windowManager.minimize();
      }
    } else {
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return AppProgressIndicator();
    }
    return Scaffold(body: WebViewDashboard(homeDir, baseUrl, urlStr));
  }
}
