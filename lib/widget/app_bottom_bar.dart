import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';

import '../core/core_config.dart';
import '../core/core_manager.dart';
import '../tr.dart';
import '../util/utils.dart';

class AppBottomBar extends StatefulWidget {
  final CoreManager coreManager;

  const AppBottomBar(this.coreManager, {super.key});

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> with WindowListener {
  ProxyMode proxyMode = ProxyMode.tun;
  TrafficState? trafficData;
  WebSocketChannel? trafficChannel;
  bool isWindowHidden = false;

  Future<void> refreshMode() async {
    final value = await widget.coreManager.getSetting();
    setState(() {
      proxyMode = value.mode;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshMode();
    windowManager.addListener(this);
    if (trafficChannel == null) {
      widget.coreManager.getTrafficChannel().then((channel) {
        trafficChannel = channel;
        trafficChannel?.stream.listen((message) {
          if (isWindowHidden) {
            return;
          }
          TrafficData value = TrafficData.fromJson(json.decode(message));
          setState(() {
            trafficData = TrafficState(rawData: value);
          });
        });
      });
    }
  }

  @override
  void onWindowFocus() {
    isWindowHidden = false;
    refreshMode();
  }

  @override
  void onWindowClose() {
    isWindowHidden = true;
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
    trafficChannel?.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            message: trafficData?.totalMsg ?? "",
            child: Text(
                trafficData?.total != null ? "${trafficData?.total}" : "0 B"),
          ),
          SizedBox(width: 16),
          Tooltip(
            message: trafficData?.uploadMsg ?? "",
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
            message: trafficData?.downloadMsg ?? "",
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
    );
  }
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

  String get total {
    var total = rawData.total.proxy.upload +
        rawData.total.proxy.download +
        rawData.total.direct.upload +
        rawData.total.direct.download;
    return formatBytes(total);
  }

  String get totalMsg {
    var proxyTotal =
        formatBytes(rawData.total.proxy.upload + rawData.total.proxy.download);
    var directTotal = formatBytes(
        rawData.total.direct.upload + rawData.total.direct.download);
    return "${tr().proxyLabel}: $proxyTotal\n\n${tr().bypassLabel}: $directTotal";
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
