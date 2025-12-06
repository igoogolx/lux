import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/model/app.dart';
import 'package:lux/widget/proxy_list_card.dart';
import 'package:provider/provider.dart';
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

  List<SubscriptionItem> subscriptionList = <SubscriptionItem>[];

  bool isLoadingProxyList = false;

  bool isLoadingProxyRadio = false;

  var isCollapsedMap = <String, bool>{};

  Future<void> refreshProxyList() async {
    final proxyListValue = await widget.coreManager.getProxyList();
    final subscriptionListValue =
        await widget.coreManager.getSubscriptionList();
    setState(() {
      proxyListGroup = proxyListValue;
      subscriptionList = subscriptionListValue.value;
      proxyListGroup.sort(subscriptionList);
      Provider.of<AppStateModel>(context, listen: false)
          .updateSelectedProxyId(proxyListGroup.selectedId);
      for (var group in proxyListGroup.groups) {
        var key = group.id;
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
        Provider.of<AppStateModel>(context, listen: false)
            .updateSelectedProxyId(id);
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
    return isCollapsedMap.containsKey(item.id)
        ? (isCollapsedMap[item.id] as bool)
        : true;
  }

  void handleCollapse(ProxyList item) {
    setState(() {
      isCollapsedMap[item.id] = !getIsCollapsed(item);
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

  void _handleQrCode(ProxyItem item) async {
    final editingUrl = "${widget.dashboardUrl}&mode=qrCode&proxyId=${item.id}";
    launchUrl(Uri.parse(editingUrl));
  }

  void _handleItemChange(ProxyItemAction action, ProxyItem item) async {
    switch (action) {
      case ProxyItemAction.delete:
        _handleDeleteItem(item);
      case ProxyItemAction.edit:
        _handleEditItem(item);
      case ProxyItemAction.qrCode:
        _handleQrCode(item);
    }
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
                    key: Key(proxyListGroup.groups[index].id),
                    isCollapsed: getIsCollapsed(proxyListGroup.groups[index]),
                    onCollapse: () =>
                        {handleCollapse(proxyListGroup.groups[index])},
                    onItemChange: _handleItemChange,
                    subscriptionList: subscriptionList,
                  );
                },
              ));
  }
}
