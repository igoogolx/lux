import 'package:flutter/gestures.dart';
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
import 'package:webview_windows/webview_windows.dart' as webview_windows;

ProcessManager? process;
var urlStr = '';

void exitApp() {
  process?.exit();
  exit(0);
}

void openDashboard() async {
  final Uri url = Uri.parse(urlStr);
  launchUrl(url);
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
    final homeDir =
        path.join(appDocumentsDir.path, '${currentVersion.major}.0');
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
    final baseUrl = 'http://localhost:$port';
    urlStr = '$baseUrl/?client_version=$currentVersion';
    final manager = CoreManager(baseUrl, process);
    await manager.ping();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 650),
      center: true,
      skipTaskbar: false,
    );

    var isWebviewSupported = true;
    if (Platform.isWindows) {
      final webviewVersion =
          await webview_windows.WebviewController.getWebViewVersion();
      if (webviewVersion == null) {
        isWebviewSupported = false;
      }
    }

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (!isWebviewSupported) {
        await windowManager.hide();
      } else {
        await windowManager.show();
        await windowManager.focus();
      }
    });

    initSystemTray(openDashboard, exitApp, isWebviewSupported);

    if (!isWebviewSupported) {
      openDashboard();
      runApp(const MaterialApp());
    } else {
      if (Platform.isWindows) {
        runApp(const MaterialApp(home: WindowsWebViewDashboard()));
      } else {
        runApp(const MaterialApp(home: MacOSWebViewDashboard()));
      }
    }
  } catch (e) {
    await notifier.show("$e");
    exitApp();
  }
}

class MacOSWebViewDashboard extends StatefulWidget {
  const MacOSWebViewDashboard({super.key});

  @override
  State<MacOSWebViewDashboard> createState() => _MacOSWebViewDashboardState();
}

class _MacOSWebViewDashboardState extends State<MacOSWebViewDashboard> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
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

class WindowsWebViewDashboard extends StatefulWidget {
  const WindowsWebViewDashboard({super.key});

  @override
  State<WindowsWebViewDashboard> createState() =>
      _WindowsWebViewDashboardState();
}

class _WindowsWebViewDashboardState extends State<WindowsWebViewDashboard> {
  final _controller = webview_windows.WebviewController();
  late double pointX = 0;
  late double pointY = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  _initScrollJs() {
    _controller.executeScript(
        "function eleCanScroll(ele) { if (ele.scrollTop > 0) { return ele; } else { ele.scrollTop++; const top = ele.scrollTop; top && (ele.scrollTop = 0); if(top > 0){ return ele; }else{  return eleCanScroll( ele.parentElement); } } }");
  }

  Future<void> initPlatformState() async {
    await _controller.initialize();
    await _controller.loadUrl(urlStr);
    _initScrollJs();
    setState(() {});
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            _setWebViewScroll(
                pointX, pointY, signal.scrollDelta.dx, signal.scrollDelta.dy);
          }
        },
        onPointerHover: (ev) {
          pointX = ev.localPosition.dx;
          pointY = ev.localPosition.dy;
        },
        child: webview_windows.Webview(
          _controller,
        ),
      );
    }
  }

  _setWebViewScroll(double x, double y, double dx, double dy) {
    debugPrint('_setWebViewScroll------$x----$y-------$dx---------$dy');
    _controller.executeScript(
        "var el = document.elementFromPoint($x,$y);  var el2 = eleCanScroll(el); el2.scrollBy($dx,$dy);");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:compositeView()
    );
  }
}
