import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lux/dashboard.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final String homeDir;

  const Home(this.homeDir, this.baseUrl, this.urlStr, {super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WindowListener {


  String? dashboardUrl;


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
    var preUrl = dashboardUrl ?? widget.urlStr;
    return Scaffold(
      body: WebViewDashboard(widget.homeDir, widget.baseUrl,preUrl)
    );
  }
}