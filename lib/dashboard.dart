import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lux/tr.dart';
import 'package:lux/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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

class TrafficState {
  final TrafficData rawData;

  TrafficState({required this.rawData});

  String get download {
    var download = rawData.speed.proxy.download + rawData.speed.direct.download;
    return formatBytes(download);
  }

  String get downloadMsg {
    return "${tr().proxyLabel}: ${formatBytes(rawData.speed.proxy.download)}/s\n\n${tr().bypassLabel}: ${formatBytes(rawData.speed.direct.download)}/s";
  }

  String get upload {
    var upload = rawData.speed.proxy.upload + rawData.speed.direct.upload;
    return formatBytes(upload);
  }

  String get uploadMsg {
    return "${tr().proxyLabel}: ${formatBytes(rawData.speed.proxy.upload)}/s\n\n${tr().bypassLabel}: ${formatBytes(rawData.speed.direct.upload)}/s";
  }
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
  TrafficState? trafficData;
  WebSocketChannel? trafficChannel;

  Timer timer = Timer(Duration.zero, () {});
  final dio = Dio();

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
    timer.cancel();
    trafficChannel?.sink.close();
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

  Future<void> refreshIsStarted() async {
    final value = await widget.coreManager.getIsStarted();
    setState(() {
      isStarted = value;
    });
  }

  Future<void> refreshCurProxyInfo() async {
    final value = await widget.coreManager.getCurProxyInfo();
    setState(() {
      curProxyInfo = value;
    });
  }

  Future<void> refreshProxyList() async {
    final value = await widget.coreManager.getProxyList();
    setState(() {
      proxyList = value;
    });
  }

  Future<void> refreshRuleList() async {
    final value = await widget.coreManager.getRuleList();
    setState(() {
      ruleList = value;
    });
  }

  Future<void> refreshMode() async {
    final value = await widget.coreManager.getMode();
    setState(() {
      proxyMode = value;
    });
  }

  Future<void> refreshData() async {
    if (trafficChannel == null) {
      widget.coreManager.getTrafficChannel().then((channel) {
        trafficChannel = channel;
        trafficChannel?.stream.listen((message) {
          TrafficData value = TrafficData.fromJson(json.decode(message));
          setState(() {
            trafficData = TrafficState(rawData: value);
          });
        });
      });
    }

    if (!isLoadingSwitch) {
      refreshIsStarted();
    }

    refreshCurProxyInfo();

    if (!isLoadingProxyRadio) {
      refreshProxyList();
    }

    if (!isLoadingRuleDropdown) {
      refreshRuleList();
    }

    refreshMode();
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
                    width: 168,
                    initialSelection: ruleList.selectedId,
                    onSelected: isLoadingRuleDropdown ? null : handleSelectRule,
                    dropdownMenuEntries: menuEntries,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(width: 4),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.0,
          ),
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: trafficData?.uploadMsg,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.arrow_upward_sharp, size: 14),
                  Text(trafficData?.upload != null
                      ? "${trafficData?.upload}/s"
                      : "0 B/s"),
                ],
              ),
            ),
            SizedBox(width: 8),
            Tooltip(
              message: trafficData?.downloadMsg,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.arrow_downward_sharp, size: 14),
                  Text(trafficData?.download != null
                      ? "${trafficData?.download}/s"
                      : "0 B/s"),
                ],
              ),
            ),
            SizedBox(width: 24),
            Tooltip(
              message: tr().proxyModeTooltip,
              child: Text(
                getModeLabel(proxyMode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
