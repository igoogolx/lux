import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lux/tr.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool isStarted = false;
  String curProxyInfo = "";
  ProxyList proxyList = ProxyList(<ProxyItem>[], "");
  RuleList ruleList = RuleList(<String>[], "");
  bool isLoadingSwitch = false;
  bool isLoadingProxyList = false;
  bool isLoadingRuleList = false;
  bool isLoadingProxyRadio = false;
  bool isLoadingRuleDropdown = false;
  ProxyMode proxyMode = ProxyMode.tun;

  Timer timer = Timer(Duration.zero, () {});
  final dio = Dio();

  _DashboardState();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    refreshData();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
    timer.cancel();
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

  Future<void> refreshData() async {
    widget.coreManager.getIsStarted().then((value) {
      setState(() {
        isStarted = value;
      });
    });
    widget.coreManager.getCurProxyInfo().then((value) {
      setState(() {
        curProxyInfo = value;
      });
    });
    widget.coreManager.getProxyList().then((value) {
      setState(() {
        proxyList = value;
      });
    });
    widget.coreManager.getRuleList().then((value) {
      setState(() {
        ruleList = value;
      });
    });
    widget.coreManager.getMode().then((value) {
      setState(() {
        proxyMode = value;
      });
    });
  }

  void onSwitchChanged(bool value) async {
    try {
      setState(() {
        isLoadingSwitch = true;
      });
      if (value) {
        await widget.coreManager.start();
        setState(() {
          isStarted = true;
        });
      } else {
        await widget.coreManager.stop();
        setState(() {
          isStarted = false;
        });
      }
    } finally {
      setState(() {
        isLoadingSwitch = false;
      });
    }
  }

  void openWebDashboard() {
    launchUrl(Uri.parse(widget.urlStr));
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

  Future<void> handleSelectRule(String? id) async {
    if (id == null) {
      return;
    }
    try {
      setState(() {
        isLoadingRuleDropdown = true;
      });
      await widget.coreManager.selectRule(id);
      setState(() {
        ruleList.selectedId = id;
      });
    } finally {
      setState(() {
        isLoadingRuleDropdown = false;
      });
    }
  }

  String getRuleLabel(String name) {
    switch (name) {
      case "proxy_all":
        return tr().proxyAllRuleLabel;
      case "proxy_gfw":
        return tr().proxyGFWRuleLabel;
      case "bypass_cn":
        return tr().bypassCNRuleLabel;
      case "bypass_all":
        return tr().bypassAllRuleLabel;
      default:
        return name;
    }
  }

  String getModeLabel(ProxyMode value) {
    switch (value) {
      case ProxyMode.tun:
        return tr().tunModeLabel;
      case ProxyMode.system:
        return tr().systemModeLabel;
      default:
        return tr().mixedModeLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<String>> menuEntries =
        UnmodifiableListView<DropdownMenuEntry<String>>(
      ruleList.rules.map<DropdownMenuEntry<String>>((String name) {
        String label = getRuleLabel(name);
        return DropdownMenuEntry(value: name, label: label);
      }),
    );

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              tooltip: tr().goWebDashboardTip,
              onPressed: openWebDashboard,
              padding: EdgeInsetsGeometry.all(0),
              icon: const Icon(
                Icons.settings,
              )),
          title: Row(
            children: [
              SizedBox(
                height: 32,
                child: FittedBox(
                  child: DropdownMenu<String>(
                    width: 160,
                    initialSelection: ruleList.selectedId,
                    onSelected: isLoadingRuleDropdown ? null : handleSelectRule,
                    dropdownMenuEntries: menuEntries,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Tooltip(
                message: tr().proxyModeTooltip,
                child: Chip(
                  label: Text(
                    getModeLabel(proxyMode),
                    style: TextStyle(color: Color.fromRGBO(17, 94, 163, 1)),
                  ),
                  backgroundColor: Color.fromRGBO(235, 243, 252, 1),
                ),
              ),
              Spacer(),
              Text(
                curProxyInfo,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: FittedBox(
                  child: Switch(
                    value: isStarted,
                    onChanged: isLoadingSwitch ? null : onSwitchChanged,
                  ),
                ),
              ),
            ],
          )),
      body: Card(
        margin: EdgeInsetsGeometry.only(left: 6, right: 6, top: 8, bottom: 8),
        child: proxyList.proxies.isEmpty
            ? SizedBox()
            : ListView.separated(
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
                    onChanged: isLoadingProxyRadio ? null : handleSelectProxy,
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
      ),
    );
  }
}
