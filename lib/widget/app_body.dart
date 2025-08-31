import 'package:flutter/material.dart';
import 'package:lux/widget/proxy_list.dart';
import 'package:window_manager/window_manager.dart';

import '../core_manager.dart';

class AppBody extends StatefulWidget {
  final CoreManager coreManager;
  final String curProxyInfo;
  final void Function(String) onCurProxyInfoChange;
  const AppBody(
      {super.key,
      required this.coreManager,
      required this.curProxyInfo,
      required this.onCurProxyInfoChange});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> with WindowListener {
  ProxyListGroup proxyListGroup =
      ProxyListGroup(<ProxyItem>[], "", <ProxyList>[]);
  bool isLoadingProxyList = false;

  bool isLoadingProxyRadio = false;

  Future<void> refreshProxyList() async {
    final value = await widget.coreManager.getProxyList();
    setState(() {
      proxyListGroup = value;
    });
  }

  Future<void> refreshData() async {
    if (!isLoadingProxyRadio) {
      refreshProxyList();
    }
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
        proxyListGroup.selectedId = id;
        var curProxy = proxyListGroup.allProxies.firstWhere((p) => p.id == id);

        var newCurProxyInfo = curProxy.name.isNotEmpty
            ? curProxy.name
            : "${curProxy.server}:${curProxy.port}";
        widget.onCurProxyInfoChange(newCurProxyInfo);
      });
    } finally {
      setState(() {
        isLoadingProxyRadio = false;
      });
    }
  }

  @override
  void onWindowFocus() {
    refreshData();
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    refreshData();
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
        groupValue: proxyListGroup.selectedId,
        onChanged: handleSelectProxy,
        child: proxyListGroup.groups.isEmpty
            ? SizedBox()
            : ListView.builder(
                itemCount: proxyListGroup.groups.length,
                itemBuilder: (context, index) {
                  return ProxyListView(
                    proxyList: proxyListGroup.groups[index],
                    key: Key(proxyListGroup.groups[index].url),
                  );
                },
              ));
  }
}
