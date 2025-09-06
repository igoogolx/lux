import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lux/util/utils.dart';
import 'package:lux/widget/app_body.dart';
import 'package:lux/widget/app_bottom_bar.dart';
import 'package:lux/widget/app_header_bar.dart';
import 'package:window_manager/window_manager.dart';

import 'core/core_manager.dart';

class Dashboard extends StatefulWidget {
  final String baseUrl;
  final String urlStr;
  final String homeDir;
  final CoreManager coreManager;

  const Dashboard(this.homeDir, this.baseUrl, this.urlStr, this.coreManager,
      {super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WindowListener {
  String curProxyInfo = "";

  _DashboardState();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    checkForUpdate();
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
        await Future.delayed(const Duration(seconds: 1));
      }
      await windowManager.hide();
    } else {
      await windowManager.hide();
    }
  }

  void onCurProxyInfoChange(String info) {
    setState(() {
      curProxyInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppHeaderBar(
            coreManager: widget.coreManager,
            urlStr: widget.urlStr,
            curProxyInfo: curProxyInfo,
            onCurProxyInfoChange: onCurProxyInfoChange,
          )),
      body: AppBody(
          coreManager: widget.coreManager,
          curProxyInfo: curProxyInfo,
          onCurProxyInfoChange: onCurProxyInfoChange),
      bottomNavigationBar: AppBottomBar(widget.coreManager),
    );
  }
}
