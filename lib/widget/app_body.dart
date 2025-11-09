import 'package:flutter/material.dart';
import 'package:lux/widget/proxy_list_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../core/core_config.dart';
import '../core/core_manager.dart';

class AppBody extends StatefulWidget {
  final CoreManager coreManager;
  final String curProxyInfo;
  final String dashboardUrl;
  final void Function(String) onCurProxyInfoChange;
  const AppBody(
      {super.key,
      required this.coreManager,
      required this.curProxyInfo,
      required this.onCurProxyInfoChange,
      required this.dashboardUrl});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> with WindowListener {
  ProxyListGroup proxyListGroup =
      ProxyListGroup(<ProxyItem>[], "", <ProxyList>[]);
  bool isLoadingProxyList = false;

  bool isLoadingProxyRadio = false;

  var isCollapsedMap = <String, bool>{};

  Future<void> refreshProxyList() async {
    final value = await widget.coreManager.getProxyList();
    setState(() {
      proxyListGroup = value;
      for (var group in proxyListGroup.groups) {
        var key = group.url;
        if (!isCollapsedMap.containsKey(key)) {
          setState(() {
            isCollapsedMap[key] = true;
          });
        }
      }
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

  bool getIsCollapsed(ProxyList item) {
    return isCollapsedMap.containsKey(item.url)
        ? (isCollapsedMap[item.url] as bool)
        : true;
  }

  void handleCollapse(ProxyList item) {
    setState(() {
      isCollapsedMap[item.url] = !getIsCollapsed(item);
    });
  }

  void _handleDeleteItem(ProxyItem item) async {
    await widget.coreManager.deleteProxies([item.id]);
    await refreshData();
  }

  void _handleEditItem(ProxyItem item) async {
    final editingUrl = "${widget.dashboardUrl}&mode=edit&proxyId=${item.id}";
    launchUrl(Uri.parse(editingUrl));
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
                  return ProxyListCard(
                    proxyList: proxyListGroup.groups[index],
                    key: Key(proxyListGroup.groups[index].url),
                    isCollapsed: getIsCollapsed(proxyListGroup.groups[index]),
                    onCollapse: () =>
                        {handleCollapse(proxyListGroup.groups[index])},
                    onDeleteItem: _handleDeleteItem,
                    onEditItem: _handleEditItem,
                  );
                },
              ));
  }
}
