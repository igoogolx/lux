import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lux/const/const.dart';
import 'package:lux/core_manager.dart' hide ProxyMode;
import 'package:lux/dashboard.dart';
import 'package:lux/model/app.dart';
import 'package:lux/tray.dart';
import 'package:lux/util/process_manager.dart';
import 'package:lux/util/utils.dart';
import 'package:lux/widget/progress_indicator.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:version/version.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';

import 'core_config.dart';

class Home extends StatefulWidget {
  final ClientMode clientMode;

  const Home(this.clientMode, {super.key});

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
  Widget? dashboardWidget;
  WebSocketChannel? eventChannel;
  late final AppLifecycleListener _listener;

  void _init(AppStateModel appState) async {
    trayManager.addListener(this);
    await windowManager.setPreventClose(true);
    var corePath = path.join(Paths.assetsBin.path, LuxCoreName.name);
    var curHomeDir = await getHomeDir();
    final port = await findAvailablePort(8000, 9000);
    var uuid = Uuid();
    var secret = uuid.v4();
    final Version currentVersion = Version.parse(await getAppVersion());
    var needElevate = true;
    var homeDirArg = '-home_dir=$curHomeDir';
    if (Platform.isWindows) {
      homeDirArg = "-home_dir=`\"$curHomeDir`\"";
      final proxyMode = await readProxyMode();
      needElevate = proxyMode != ProxyMode.system;
    }
    final process = ProcessManager(
        corePath, [homeDirArg, '-port=$port', '-secret=$secret'], needElevate);
    var curBaseUrl = '127.0.0.1:$port';
    var curHttpUrl = 'http://$curBaseUrl';
    var curUrlStr =
        '$curHttpUrl/?client_version=$currentVersion&token=$secret&theme=${appState.theme == ThemeMode.dark ? 'dark' : 'light'}';
    debugPrint("dashboard url: $curUrlStr");
    coreManager = CoreManager(curBaseUrl, process, secret, () {
      setState(() {
        isCoreReady.value = true;
      });
      if (eventChannel == null) {
        coreManager?.getEventChannel().then((channel) {
          eventChannel = channel;
          eventChannel?.stream.listen((rawData) async {
            if (rawData is! String) {
              return;
            }
            final message = json.decode(rawData);
            if (message is! Map<String, dynamic>) {
              return;
            }
            if (!(message.containsKey('type') && message['type'] is String)) {
              return;
            }

            switch (message['type']) {
              case "set_theme":
                {
                  if (!(message.containsKey('value') &&
                      message['value'] is String)) {
                    return;
                  }
                  appState.updateTheme(convertTheme(message['value']));
                }
              case "set_language":
                {
                  if (!(message.containsKey('value') &&
                      message['value'] is String)) {
                    return;
                  }
                  appState.updateLocale(convertLocale(message['value']));
                  if (Platform.isWindows) {
                    initSystemTray();
                  }
                }
              case "set_auto_launch":
                {
                  if (!(message.containsKey('value') &&
                      message['value'] is bool)) {
                    return;
                  }
                  if (message['value']) {
                    await launchAtStartup.enable();
                  } else {
                    await launchAtStartup.disable();
                  }
                }
              case 'open_home_dir':
                {
                  launchUrl(Uri.file(homeDir));
                }
              case 'open_web_dashboard':
                {
                  launchUrl(Uri.parse(urlStr));
                }
              case 'set_web_dashboard_is_ready':
                {
                  isWebviewReady.value = true;
                }
              case 'exit_app':
                {
                  await coreManager?.exitCore();
                  exitApp();
                }
            }
          });
        });
      }
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

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onExitRequested: _handleExitRequest);
    _init(Provider.of<AppStateModel>(context, listen: false));
  }

  Future<AppExitResponse> _handleExitRequest() async {
    if (Platform.isMacOS) {
      await coreManager?.safeExit();
    }
    return AppExitResponse.exit;
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
    return Dashboard(homeDir, baseUrl, urlStr, coreManager!);
  }
}
