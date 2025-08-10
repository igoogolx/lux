import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lux/utils.dart';
import 'package:lux/widget/app_bottom_bar.dart';
import 'package:lux/widget/app_header_bar.dart';
import 'package:window_manager/window_manager.dart';

import 'core_manager.dart';

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
  ProxyList proxyList = ProxyList(<ProxyItem>[], "");

  String curProxyInfo = "";

  bool isLoadingProxyList = false;

  bool isLoadingProxyRadio = false;

  _DashboardState();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    refreshData();

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

  @override
  void onWindowFocus() {
    refreshData();
  }

  Future<void> refreshProxyList() async {
    final value = await widget.coreManager.getProxyList();
    setState(() {
      proxyList = value;
    });
  }

  Future<void> handleSelectProxy(String? id) async {
    if (id == null) {
      return;
    }
    try {
      setState(() {
        isLoadingProxyRadio = true;
      });
      await widget.coreManager.selectProxy(id);
      setState(() {
        proxyList.selectedId = id;
        var curProxy = proxyList.proxies.firstWhere((p) => p.id == id);
        curProxyInfo = curProxy.name.isNotEmpty
            ? curProxy.name
            : "${curProxy.server}:${curProxy.port}";
      });
    } finally {
      setState(() {
        isLoadingProxyRadio = false;
      });
    }
  }

  Future<void> refreshData() async {
    if (!isLoadingProxyRadio) {
      refreshProxyList();
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
          preferredSize: Size.fromHeight(100.0),
          child: AppHeaderBar(
            coreManager: widget.coreManager,
            urlStr: widget.urlStr,
            curProxyInfo: curProxyInfo,
            onCurProxyInfoChange: onCurProxyInfoChange,
          )),
      body: ListView(
        children: [
          Card(
            margin:
                EdgeInsetsGeometry.only(left: 6, right: 6, top: 8, bottom: 8),
            child: proxyList.proxies.isEmpty
                ? SizedBox()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsetsGeometry.all(0),
                    itemCount: proxyList.proxies.length,
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        title: Text(
                          proxyList.proxies[index].name.isNotEmpty
                              ? proxyList.proxies[index].name
                              : "${proxyList.proxies[index].server}:${proxyList.proxies[index].port}",
                          style: TextStyle(fontSize: 12),
                        ),
                        value: proxyList.proxies[index].id,
                        groupValue: proxyList.selectedId,
                        onChanged:
                            isLoadingProxyRadio ? null : handleSelectProxy,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1, // Control the space the divider takes up
                        thickness: 1, // Control the line's thickness
                        indent: 20, // Left padding
                        endIndent: 20, // Right padding
                      );
                    },
                  ),
          )
        ],
      ),
      bottomNavigationBar: AppBottomBar(widget.coreManager),
    );
  }
}
