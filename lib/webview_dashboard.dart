import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lux/model/app.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_win_floating/webview.dart';
import 'package:webview_win_floating/webview_plugin.dart';
import 'package:window_manager/window_manager.dart';

class WebViewDashboard extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final String homeDir;
  final void Function(JavaScriptMessage, AppStateModel appState)
      onChannelMessage;

  const WebViewDashboard(
      this.homeDir, this.baseUrl, this.urlStr, this.onChannelMessage,
      {super.key});

  @override
  State<WebViewDashboard> createState() => _WebViewDashboardState();
}

class _WebViewDashboardState extends State<WebViewDashboard>
    with WindowListener {
  late WebViewController? _controller;

  _WebViewDashboardState();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams();
    } else {
      String cacheDir = path.join(widget.homeDir, 'cache_webview');
      params = WindowsPlatformWebViewControllerCreationParams(
          userDataFolder: cacheDir);
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller.setNavigationDelegate(
      NavigationDelegate(onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith(widget.baseUrl)) {
          return NavigationDecision.navigate;
        }
        launchUrl(Uri.parse(request.url));
        return NavigationDecision.prevent;
      }),
    );

    controller.addJavaScriptChannel('ClientChannel',
        onMessageReceived: (m) =>
            widget.onChannelMessage(m, Provider.of<AppStateModel>(context)));

    controller.loadRequest(Uri.parse(widget.urlStr));

    controller.enableZoom(false);

    if (controller.platform is WindowsPlatformWebViewController) {
      (controller.platform as WindowsPlatformWebViewController)
          .setStatusBar(false);
      if (kDebugMode) {
        (controller.platform as WindowsPlatformWebViewController)
            .openDevTools();
      }
    }

    if (controller.platform is WebKitWebViewController) {
      if (kDebugMode) {
        (controller.platform as WebKitWebViewController).setInspectable(true);
      }
    }

    _controller = controller;
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
    if (_controller != null) {
      return WebViewWidget(controller: _controller as WebViewController);
    }
    return Text("Disposed");
  }
}
