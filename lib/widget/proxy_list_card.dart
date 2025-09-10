import 'package:flutter/material.dart';
import 'package:lux/const/const.dart';
import 'package:lux/tr.dart';
import 'package:lux/widget/proxy_list_item.dart';

import '../core/core_config.dart';

class ProxyListCard extends StatefulWidget {
  final ProxyList proxyList;

  const ProxyListCard({super.key, required this.proxyList});

  @override
  State<ProxyListCard> createState() => _ProxyListCardState();
}

class _ProxyListCardState extends State<ProxyListCard> {
  bool isCollapsed = true;
  String? previewInfo;

  @override
  void initState() {
    super.initState();
    if (widget.proxyList.url != localServersGroupKey) {
      try {
        final parsedUrl = Uri.parse(widget.proxyList.url);
        setState(() {
          previewInfo = parsedUrl.host;
        });
      } catch (e) {
        debugPrint("error parsing URL: $e");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proxyList = widget.proxyList;

    return Card(
      margin: EdgeInsetsGeometry.only(left: 6, right: 6, top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
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
                    Icon(isCollapsed
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    Text(
                      previewInfo is String
                          ? previewInfo as String
                          : tr().localServer,
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              )
            ],
          ),
          proxyList.proxies.isEmpty || !isCollapsed
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
