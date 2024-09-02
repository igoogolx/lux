import 'package:flutter/material.dart';
import 'package:lux/core_manager.dart';
import 'package:lux/elevate.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/tray.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:lux/const/const.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:version/version.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_win_floating/webview_win_floating.dart';

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
    if (Platform.isWindows &&
        !await FlutterSingleInstance.platform.isFirstInstance()) {
      await notifier.show("App is already running");
      exitApp();
    }

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
    process = ProcessManager(corePath, ['-home_dir=$homeDir', '-port=$port']);
    await process?.run();
    process?.watchExit();
    baseUrl = 'http://localhost:$port';
    urlStr = '$baseUrl/?client_version=$currentVersion';
    final manager = CoreManager(baseUrl, process);
    await manager.ping();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 650),
      center: true,
      skipTaskbar: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    if (Platform.isWindows) {
      initSystemTray(exitApp, () {
        windowManager.show();
        windowManager.focus();
      });
    }

    runApp(const MaterialApp(home: WebViewDashboard()));
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}

class WebViewDashboard extends StatefulWidget {
  const WebViewDashboard({super.key});

  @override
  State<WebViewDashboard> createState() => _WebViewDashboardState();
}

class _WebViewDashboardState extends State<WebViewDashboard>
    with WindowListener {
  late final WebViewController _controller;

  void _init() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
    setState(() {});
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
  void initState() {
    super.initState();
    _init();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      String cacheDir = path.join(homeDir, 'cache_webview');
      params = WindowsPlatformWebViewControllerCreationParams(
          userDataFolder: cacheDir);
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith(baseUrl)) {
            return NavigationDecision.navigate;
          }
          launchUrl(Uri.parse(request.url));
          return NavigationDecision.prevent;
        },
      ),
    );

    controller.loadRequest(Uri.parse(urlStr));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
