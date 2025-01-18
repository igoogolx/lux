import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lux/dashboard.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final WebViewEnvironment? webViewEnvironment;
  final bool isWebViewAvailable;

  const Home(this.baseUrl, this.urlStr, this.webViewEnvironment,this.isWebViewAvailable, {super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WindowListener {
  void _init() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
    setState(() {});
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
    if(!widget.isWebViewAvailable){
      windowManager.focus();
      return Scaffold(body: Center(child: Text("WebView is not available.") ,));
    }
    return Scaffold(
        body: WebViewDashboard(
            widget.baseUrl, widget.urlStr, widget.webViewEnvironment));
  }
}
