import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/dashboard.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/progress_indicator.dart';
import 'package:lux/tr.dart';
import 'package:lux/tray.dart';
import 'package:lux/utils.dart';
import 'package:lux/webview_dashboard.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core_config.dart';

class Home extends StatefulWidget {
  final ThemeMode theme;
  final LocaleModel defaultLocalModel;
  final ClientMode clientMode;

  const Home(this.theme, this.defaultLocalModel, this.clientMode, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

Future<void> initClient(CoreManager? coreManager) async {
  await setAutoConnect(coreManager);
  await setAutoLaunch(coreManager);
}

class _HomeState extends State<Home> with TrayListener {
  String baseUrl = "";
  String urlStr = "";
  String homeDir = "";
  CoreManager? coreManager;
  ValueNotifier<bool> isCoreReady = ValueNotifier<bool>(false);
  ValueNotifier<bool> isWebviewReady = ValueNotifier<bool>(false);
  bool hasError = false;
  Widget? dashboardWidget;

  void _init() async {
    trayManager.addListener(this);
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
    var curBaseUrl = '127.0.0.1:$port';
    var curHttpUrl = 'http://$curBaseUrl';
    var curUrlStr =
        '$curHttpUrl/?client_version=$currentVersion&token=$secret&theme=${widget.theme == ThemeMode.dark ? 'dark' : 'light'}';
    debugPrint("dashboard url: $curUrlStr");
    coreManager = CoreManager(curBaseUrl, process, secret, () {
      setState(() {
        isCoreReady.value = true;
      });
    }, () async {
      if (Platform.isMacOS) {
        var isFullScreen = await windowManager.isFullScreen();
        if (isFullScreen) {
          await windowManager.setFullScreen(false);
        }
      }
    });

    setState(() {
      homeDir = curHomeDir;
      baseUrl = curHttpUrl;
      urlStr = curUrlStr;
    });

    if (Platform.isWindows) {
      initSystemTray();
    }

    isCoreReady.addListener(() {
      if (isCoreReady.value) {
        initClient(coreManager);
      }
    });
    await coreManager?.run();
  }

  Future<void> onChannelMessage(JavaScriptMessage value) async {
    var msg = value.message;
    debugPrint("channel message from webview :$msg");
    switch (msg) {
      case 'enableAutoLaunch':
        {
          launchAtStartup.enable();
        }
      case 'disableAutoLaunch':
        {
          launchAtStartup.disable();
        }
      case 'openHomeDir':
        {
          launchUrl(Uri.file(homeDir));
        }
      case 'openWebDashboard':
        {
          launchUrl(Uri.parse(urlStr));
        }
      case 'ready':
        {
          isWebviewReady.value = true;
        }
      case 'changeLanguage':
        {
          var latestLocaleValue = await getLocale();
          widget.defaultLocalModel.set(latestLocaleValue);
          //tray should be updated after material app is re-rebuilt
          await Future.delayed(const Duration(seconds: 1));
          if (Platform.isWindows) {
            initSystemTray();
          }
        }
      case 'exitApp':
        {
          exitApp();
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'open_dashboard') {
      final Uri url = Uri.parse(urlStr);
      launchUrl(url);
    } else if (menuItem.key == 'exit_app') {
      await coreManager?.exitCore();
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (coreManager == null || !isCoreReady.value) {
      return Scaffold(body: AppProgressIndicator());
    }
    if (widget.clientMode == ClientMode.light) {
      return Dashboard(homeDir, baseUrl, urlStr, coreManager!);
    }

    return Scaffold(
        body: WebViewDashboard(homeDir, baseUrl, urlStr, onChannelMessage));
  }
}
