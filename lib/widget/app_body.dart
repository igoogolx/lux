import 'package:flutter/material.dart';
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
  ProxyList proxyList = ProxyList(<ProxyItem>[], "");
  bool isLoadingProxyList = false;

  bool isLoadingProxyRadio = false;

  Future<void> refreshProxyList() async {
    final value = await widget.coreManager.getProxyList();
    setState(() {
      proxyList = value;
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
        proxyList.selectedId = id;
        var curProxy = proxyList.proxies.firstWhere((p) => p.id == id);

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
    return ListView(
      children: [
        Card(
          margin: EdgeInsetsGeometry.only(left: 6, right: 6, top: 8, bottom: 8),
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
        )
      ],
    );
  }
}
