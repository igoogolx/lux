import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class WebViewDashboard extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final WebViewEnvironment? webViewEnvironment;

  const WebViewDashboard(this.baseUrl, this.urlStr, this.webViewEnvironment,
      {super.key});

  @override
  State<WebViewDashboard> createState() => _WebViewDashboard();
}

class _WebViewDashboard extends State<WebViewDashboard> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: webViewKey,
      webViewEnvironment: widget.webViewEnvironment,
      initialUrlRequest: URLRequest(url: WebUri(widget.urlStr)),
      initialSettings: settings,

      onWebViewCreated: (controller) {
        webViewController = controller;
        controller.addJavaScriptHandler(handlerName: 'open', callback: (args) {
          if(args.isNotEmpty){
            if(args[0] is String){
              var filePath = args[0] as String;
              final Uri fileUrl = Uri.parse(filePath);
              launchUrl(fileUrl);
            }
          }
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url!;

        if (uri.toString().startsWith(widget.baseUrl)) {
          return NavigationActionPolicy.ALLOW;
        }

        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
          );
        }
        return NavigationActionPolicy.CANCEL;
      },
      onReceivedError: (controller, request, error) {},
      onProgressChanged: (controller, progress) {
        if (progress == 100) {
          windowManager.show();
          windowManager.focus();
        }
      },
    );
  }
}
