import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  Timer timer = Timer(Duration.zero, () {});
  final dio = Dio();

  _DashboardState();

  @override
  void initState() {
    super.initState();

    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer t) {
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
    });

    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
    timer.cancel();
  }

  @override
  void onWindowClose() async {}

  void onSwitchChanged(bool value) async {
    debugPrint("Switch changed: $value");
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
  }

  void openWebDashboard() {
    launchUrl(Uri.parse(widget.urlStr));
  }

  Future<void> handleSelectProxy(String? id) async {
    if (id == null) {
      return;
    }
    await widget.coreManager.selectProxy(id);
    setState(() {
      proxyList.selectedId = id;
    });
  }

  Future<void> handleSelectRule(String? id) async {
    if (id == null) {
      return;
    }
    await widget.coreManager.selectRule(id);
    setState(() {
      ruleList.selectedId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<String>> menuEntries =
        UnmodifiableListView<DropdownMenuEntry<String>>(
      ruleList.rules.map<DropdownMenuEntry<String>>(
          (String name) => DropdownMenuEntry(value: name, label: name)),
    );

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          IconButton(
              tooltip: "Go to Web Dashboard",
              onPressed: openWebDashboard,
              icon: const Icon(
                Icons.settings,
                size: 20,
              )),
          SizedBox(
            height: 32,
            child: FittedBox(
              fit: BoxFit.fill,
              child: DropdownMenu<String>(
                initialSelection: ruleList.selectedId,
                onSelected: handleSelectRule,
                dropdownMenuEntries: menuEntries,
              ),
            ),
          ),
          Spacer(),
          Text(
            curProxyInfo,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            width: 48,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value: isStarted,
                activeColor: Colors.blue,
                onChanged: onSwitchChanged,
              ),
            ),
          ),
        ],
      )),
      body: proxyList.proxies.isEmpty
          ? SizedBox()
          : ListView.builder(
              padding: EdgeInsetsGeometry.all(0),
              itemCount: proxyList.proxies.length,
              prototypeItem: RadioListTile<String>(
                title: Text(proxyList.proxies.first.name,
                    style: TextStyle(fontSize: 14)),
                value: proxyList.proxies.first.id,
                groupValue: proxyList.selectedId,
                onChanged: handleSelectProxy,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                    title: RadioListTile<String>(
                  title: Text(
                    proxyList.proxies[index].name,
                    style: TextStyle(fontSize: 14),
                  ),
                  value: proxyList.proxies[index].id,
                  groupValue: proxyList.selectedId,
                  onChanged: handleSelectProxy,
                ));
              },
            ),
    );
  }
}
