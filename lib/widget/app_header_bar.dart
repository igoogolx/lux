import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';

import '../core_manager.dart';
import '../tr.dart';

class AppHeaderBar extends StatefulWidget {
  final CoreManager coreManager;
  final String curProxyInfo;
  final void Function(String) onCurProxyInfoChange;

  const AppHeaderBar(
      {super.key,
      required this.coreManager,
      required this.urlStr,
      required this.curProxyInfo,
      required this.onCurProxyInfoChange});

  final String urlStr;

  @override
  State<AppHeaderBar> createState() => _State();
}

class _State extends State<AppHeaderBar> with WindowListener {
  bool isStarted = false;
  RuleList ruleList = RuleList(<String>[], "");
  bool isLoadingSwitch = false;
  bool isLoadingRuleList = false;
  bool isLoadingRuleDropdown = false;
  WebSocketChannel? runtimeStatusChannel;

  void openWebDashboard() {
    launchUrl(Uri.parse(widget.urlStr));
  }

  Future<void> refreshData() async {
    if (!isLoadingSwitch) {
      refreshIsStarted();
    }

    refreshCurProxyInfo();

    if (!isLoadingRuleDropdown) {
      refreshRuleList();
    }
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
      widget.onCurProxyInfoChange(value);
    });
  }

  Future<void> refreshRuleList() async {
    final value = await widget.coreManager.getRuleList();
    setState(() {
      ruleList = value;
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

  @override
  void dispose() {
    windowManager.removeListener(this);
    runtimeStatusChannel?.sink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    refreshData();

    if (runtimeStatusChannel == null) {
      widget.coreManager.getRuntimeStatusChannel().then((channel) {
        runtimeStatusChannel = channel;
        runtimeStatusChannel?.stream.listen((message) {
          RuntimeStatus value = RuntimeStatus.fromJson(json.decode(message));
          setState(() {
            if (!isLoadingSwitch) {
              isStarted = value.isStarted;
            }
          });
        });
      });
    }
  }

  @override
  void onWindowFocus() {
    refreshData();
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
    return AppBar(
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
                  width: 180,
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
              widget.curProxyInfo,
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
        ));
  }
}
