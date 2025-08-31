import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:lux/const/const.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/tr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<int> findAvailablePort(int startPort, int endPort) async {
  for (int port = startPort; port <= endPort; port++) {
    try {
      final serverSocket = await ServerSocket.bind("127.0.0.1", port);
      await serverSocket.close();
      return port;
    } catch (e) {
      // Port is not available
    }
  }
  throw Exception('No available port found in range $startPort-$endPort');
}

/// Must be top-level function
Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class CoreManager {
  final String token;
  final ProcessManager? coreProcess;
  final String baseUrl;

  final Function onReady;
  final Function onOsSleep;
  final FlutterDesktopSleep flutterDesktopSleep = FlutterDesktopSleep();
  final dio = Dio();
  var needRestart = false;
  late String baseHttpUrl;
  late String baseWsUrl;
  WebSocketChannel? _trafficChannel;
  WebSocketChannel? _runtimeStatusChannel;
  WebSocketChannel? _eventChannel;

  Future<void> powerMonitorHandler(String? s) async {
    if (s != null) {
      if (s == 'sleep') {
        onOsSleep();
        final managerRes = await dio.get('$baseHttpUrl/manager');
        var isStarted = managerRes.data['isStarted'];
        if (isStarted is bool && isStarted) {
          final settingRes = await dio.get('$baseHttpUrl/setting');
          var mode = settingRes.data['setting']['mode'];
          if (mode == "tun" || mode == "mixed") {
            needRestart = true;
            await stop();
          }
        }
      } else if (s == 'woke_up') {
        if (needRestart) {
          needRestart = false;
          final List<ConnectivityResult> connectivityResult =
              await (Connectivity().checkConnectivity());
          if (connectivityResult.contains(ConnectivityResult.none)) {
            notifier.show(tr().noConnectionMsg);
            return;
          }
          await Future.delayed(const Duration(seconds: 2));
          await start();
          notifier.show(tr().reconnectedMsg);
        }
      } else if (s == 'terminate_app') {
        exitCore();
        exit(0);
      }
    }
  }

  CoreManager(this.baseUrl, this.coreProcess, this.token, this.onReady,
      this.onOsSleep) {
    baseHttpUrl = "http://$baseUrl";
    baseWsUrl = "ws://$baseUrl";
    dio.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      final customHeaders = {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      };
      options.headers.addAll(customHeaders);
      return handler.next(options);
    }));
    if (Platform.isMacOS) {
      flutterDesktopSleep.setWindowSleepHandler(powerMonitorHandler);
    }
    if (Platform.isWindows) {
      FlutterWindowClose.setWindowShouldCloseHandler(powerMonitorHandler);
    }

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      // Received changes in available connectivity types!

      if (result.contains(ConnectivityResult.none)) {
        final managerRes = await dio.get('$baseHttpUrl/manager');
        var isStarted = managerRes.data['isStarted'];
        if (isStarted is bool && isStarted) {
          await stop();
          notifier.show(tr().noConnectionMsg);
        }
      }
      if (kDebugMode) {
        print(result);
      }
    });
  }

  Future<void> makeRequestUntilSuccess(String url) async {
    final stopwatch = Stopwatch();
    stopwatch.start(); // Start the stopwatch

    while (stopwatch.elapsedMilliseconds < 15000) {
      try {
        final response = await dio.get(url);

        // Check if the request was successful
        if (response.statusCode == 200) {
          return; // Exit the function if the request succeeds
        } else {
          await makeRequestUntilSuccess(url);
        }
      } catch (e) {
        Future.delayed(const Duration(milliseconds: 150));
        debugPrint(e.toString());
      }
    }

    throw Exception('timeout');
  }

  Future<void> ping() async {
    await makeRequestUntilSuccess('$baseHttpUrl/ping');
  }

  Future<void> stop() async {
    await dio.post('$baseHttpUrl/manager/stop',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
  }

  Future<void> start() async {
    await dio.post('$baseHttpUrl/manager/start',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
  }

  Future<bool> getIsStarted() async {
    final managerRes = await dio.get('$baseHttpUrl/manager',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
    var isStarted = managerRes.data['isStarted'];
    if (isStarted is bool) {
      return isStarted;
    }
    return false;
  }

  Future<String> getCurProxyInfo() async {
    final managerRes = await dio.get('$baseHttpUrl/proxies/cur-proxy');
    var name = managerRes.data['name'];
    if (name is String && name.isNotEmpty) {
      return name;
    }
    var addr = managerRes.data['addr'];
    if (addr is String && addr.isNotEmpty) {
      return addr;
    }
    return "";
  }

  Future<ProxyListGroup> getProxyList() async {
    final proxiesRes = await dio.get('$baseHttpUrl/proxies');
    return ProxyListGroup.fromJson(proxiesRes.data);
  }

  Future<RuleList> getRuleList() async {
    final rulesRes = await dio.get('$baseHttpUrl/rules');
    return RuleList.fromJson(rulesRes.data);
  }

  Future<void> selectProxy(String id) async {
    await dio.post('$baseHttpUrl/selected/proxy', data: {'id': id});
  }

  Future<void> selectRule(String id) async {
    await dio.post('$baseHttpUrl/selected/rule', data: {'id': id});
  }

  Future<ProxyMode> getMode() async {
    final settingRes = await dio.get('$baseHttpUrl/setting');
    if (!(settingRes.data.containsKey('setting') &&
        settingRes.data['setting'] is Map<String, dynamic>)) {
      return ProxyMode.mixed;
    }

    var setting = settingRes.data['setting'];

    if (setting.containsKey('mode') && setting['mode'] is String) {
      if (setting['mode'] == 'tun') {
        return ProxyMode.tun;
      }
      if (setting['mode'] == 'system') {
        return ProxyMode.system;
      }
    }

    return ProxyMode.mixed;
  }

  Future<void> exitCore() async {
    if (Platform.isWindows) {
      try {
        await dio.post('$baseHttpUrl/manager/exit');
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    try {
      coreProcess?.exit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> restart() async {
    coreProcess?.exit();
    await coreProcess?.run();
  }

  Future<void> run() async {
    coreProcess?.run().then((_) {
      ping().then((value) {
        onReady();
      });
    });
  }

  Future<WebSocketChannel?> getTrafficChannel() async {
    _trafficChannel ??=
        WebSocketChannel.connect(Uri.parse('$baseWsUrl/traffic?token=$token'));

    return _trafficChannel;
  }

  Future<WebSocketChannel?> getRuntimeStatusChannel() async {
    _runtimeStatusChannel ??= WebSocketChannel.connect(
        Uri.parse('$baseWsUrl/heartbeat/runtime-status?token=$token'));

    return _runtimeStatusChannel;
  }

  Future<WebSocketChannel?> getEventChannel() async {
    _eventChannel ??=
        WebSocketChannel.connect(Uri.parse('$baseWsUrl/event?token=$token'));

    return _eventChannel;
  }
}

class ProxyItem {
  final String id;
  final String name;
  final String? server;
  final int? port;
  final String? subscriptionUrl;

  ProxyItem(this.id, this.name, this.server, this.port, this.subscriptionUrl);

  ProxyItem.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as String),
        name = (json['name'] as String),
        server = (json['server'] as String),
        subscriptionUrl = (json['subscriptionUrl'] is String
            ? json['subscriptionUrl'] as String
            : null),
        port = (json['port'] as int);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ProxyListGroup {
  late String selectedId;
  late List<ProxyItem> allProxies;
  late List<ProxyList> groups;

  ProxyListGroup(this.allProxies, this.selectedId, this.groups);

  ProxyListGroup.fromJson(Map<String, dynamic> json) {
    allProxies = json['proxies'] != null
        ? (json['proxies'] as List)
            .map((asset) => ProxyItem.fromJson(asset as Map<String, dynamic>))
            .toList()
        : <ProxyItem>[];
    groups = convertListToGroup(allProxies);
    selectedId = (json['selectedId'] as String);
  }

  List<ProxyList> convertListToGroup(List<ProxyItem> items) {
    Map<String, List<ProxyItem>> groupMap = {};
    for (var item in items) {
      if (item.subscriptionUrl is String) {
        var groupName = item.subscriptionUrl as String;
        if (!groupMap.containsKey(groupName)) {
          groupMap[groupName] = [];
        }
        groupMap[groupName]!.add(item);
      } else {
        if (!groupMap.containsKey(localServersGroupKey)) {
          groupMap[localServersGroupKey] = [];
        }
        groupMap[localServersGroupKey]!.add(item);
      }
    }

    List<ProxyList> groups = [];
    groupMap.forEach((groupName, proxies) {
      groups.add(ProxyList(proxies, groupName));
    });

    return groups;
  }
}

class ProxyList {
  final List<ProxyItem> proxies;
  final String url;

  ProxyList(this.proxies, this.url);

  Map<String, dynamic> toJson() =>
      {'proxies': proxies.map((asset) => asset.toJson()).toList()};
}

class RuleList {
  final List<String> rules;
  String selectedId;

  RuleList(this.rules, this.selectedId);

  RuleList.fromJson(Map<String, dynamic> json)
      : rules = json['rules'] != null
            ? (json['rules'] as List).map((asset) => asset as String).toList()
            : <String>[],
        selectedId = (json['selectedId'] as String);

  Map<String, dynamic> toJson() => {'rules': rules};
}

// Define the data classes
class Speed {
  final Proxy proxy;
  final Direct direct;

  Speed({required this.proxy, required this.direct});

  factory Speed.fromJson(Map<String, dynamic> json) {
    return Speed(
      proxy: Proxy.fromJson(json['proxy']),
      direct: Direct.fromJson(json['direct']),
    );
  }
}

class Total {
  final Proxy proxy;
  final Direct direct;

  Total({required this.proxy, required this.direct});

  factory Total.fromJson(Map<String, dynamic> json) {
    return Total(
      proxy: Proxy.fromJson(json['proxy']),
      direct: Direct.fromJson(json['direct']),
    );
  }
}

class Proxy {
  final int upload;
  final int download;

  Proxy({required this.upload, required this.download});

  factory Proxy.fromJson(Map<String, dynamic> json) {
    return Proxy(
      upload: json['upload'],
      download: json['download'],
    );
  }
}

class Direct {
  final int upload;
  final int download;

  Direct({required this.upload, required this.download});

  factory Direct.fromJson(Map<String, dynamic> json) {
    return Direct(
      upload: json['upload'],
      download: json['download'],
    );
  }
}

class TrafficData {
  final Speed speed;
  final Total total;

  TrafficData({required this.speed, required this.total});

  factory TrafficData.fromJson(Map<String, dynamic> json) {
    return TrafficData(
      speed: Speed.fromJson(json['speed']),
      total: Total.fromJson(json['total']),
    );
  }
}

enum ProxyMode { tun, system, mixed }

class RuntimeStatus {
  final String addr;
  final String name;
  final bool isStarted;

  RuntimeStatus(
      {required this.addr, required this.name, required this.isStarted});

  factory RuntimeStatus.fromJson(Map<String, dynamic> json) {
    return RuntimeStatus(
      addr: json['addr'] is String ? json['addr'] : '',
      name: json['name'] is String ? json['name'] : '',
      isStarted: json['isStarted'] is bool ? json['isStarted'] : false,
    );
  }
}
