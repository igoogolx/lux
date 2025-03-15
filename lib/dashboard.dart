import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_win_floating/webview.dart';
import 'package:webview_win_floating/webview_plugin.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

class WebViewDashboard extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final String homeDir;

  const WebViewDashboard(this.homeDir, this.baseUrl, this.urlStr,  {super.key});

  @override
  State<WebViewDashboard> createState() => _WebViewDashboardState();
}

class _WebViewDashboardState extends State<WebViewDashboard> {
  late WebViewController? _controller;

  _WebViewDashboardState();

  @override
  void initState() {
    super.initState();
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
      }, onPageFinished: (String url) async {
        await windowManager.show();
        await windowManager.focus();
      }),
    );

    controller.loadRequest(Uri.parse(widget.urlStr));

    if(controller is WindowsPlatformWebViewController){
      WindowsPlatformWebViewController winWebViewController = controller as WindowsPlatformWebViewController;
      winWebViewController.setStatusBar(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    if(_controller !=null){
      return Scaffold(
        body: WebViewWidget(controller: _controller as WebViewController),
      );
    }
    return Text("Disposed");
  }
}
