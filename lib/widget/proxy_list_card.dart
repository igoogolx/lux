import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/tr.dart';
import 'package:lux/widget/proxy_list_item.dart';

import '../core/core_config.dart';

class ProxyListCard extends StatefulWidget {
  final ProxyList proxyList;
  final Function onCollapse;
  final bool isCollapsed;
  final List<SubscriptionItem> subscriptionList;

  final void Function(ProxyItemAction action, ProxyItem item) onItemChange;

  const ProxyListCard({
    super.key,
    required this.proxyList,
    required this.onCollapse,
    required this.isCollapsed,
    required this.onItemChange,
    required this.subscriptionList,
  });

  @override
  State<ProxyListCard> createState() => _ProxyListCardState();
}

class _ProxyListCardState extends State<ProxyListCard> {
  String getTitle() {
    if (widget.proxyList.id != localServersGroupKey) {
      try {
        var filteredSubscriptions = widget.subscriptionList
            .where((item) => item.id == widget.proxyList.id);
        var curSubscription = filteredSubscriptions.firstOrNull;
        if (curSubscription != null) {
          if (curSubscription.name.isNotEmpty) {
            return curSubscription.name;
          }
          return Uri.parse(curSubscription.url).host;
        }
      } catch (e) {
        return "invalid proxy group title";
      }
    }
    return tr().localServer;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proxyList = widget.proxyList;
    final title = getTitle();

    return Card(
      margin: EdgeInsetsGeometry.only(left: 6, right: 6, top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  widget.onCollapse();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return Colors.transparent;
                    },
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      return Colors.transparent;
                    },
                  ),
                ),
                child: Row(
                  children: [
                    Icon(widget.isCollapsed
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    Text(
                      title,
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              )
            ],
          ),
          proxyList.proxies.isEmpty || !widget.isCollapsed
              ? SizedBox()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsetsGeometry.all(0),
                  itemCount: proxyList.proxies.length,
                  itemBuilder: (context, index) {
                    return ProxyListItem(
                      key: Key(proxyList.proxies[index].id),
                      item: proxyList.proxies[index],
                      onChange: (action) =>
                          widget.onItemChange(action, proxyList.proxies[index]),
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
                )
        ],
      ),
    );
  }
}
