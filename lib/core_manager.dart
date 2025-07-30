import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';
import 'package:lux/tr.dart';

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

  Future<void> powerMonitorHandler(String? s) async {
    if (s != null) {
      if (s == 'sleep') {
        onOsSleep();
        final managerRes = await dio.get('$baseUrl/manager');
        var isStarted = managerRes.data['isStarted'];
        if (isStarted is bool && isStarted) {
          final settingRes = await dio.get('$baseUrl/setting');
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
        final managerRes = await dio.get('$baseUrl/manager');
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
    await makeRequestUntilSuccess('$baseUrl/ping');
  }

  Future<void> stop() async {
    await dio.post('$baseUrl/manager/stop');
  }

  Future<void> start() async {
    await dio.post('$baseUrl/manager/start');
  }

  Future<bool> getIsStarted() async {
    final managerRes = await dio.get('$baseUrl/manager');
    var isStarted = managerRes.data['isStarted'];
    if (isStarted is bool) {
      return isStarted;
    }
    return false;
  }

  Future<String> getCurProxyInfo() async {
    final managerRes = await dio.get('$baseUrl/proxies/cur-proxy');
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

  Future<ProxyList> getProxyList() async {
    final proxiesRes = await dio.get('$baseUrl/proxies');
    return ProxyList.fromJson(proxiesRes.data);
  }

  Future<RuleList> getRuleList() async {
    final rulesRes = await dio.get('$baseUrl/rules');
    return RuleList.fromJson(rulesRes.data);
  }

  Future<void> selectProxy(String id) async {
    await dio.post('$baseUrl/selected/proxy', data: {'id': id});
  }

  Future<void> selectRule(String id) async {
    await dio.post('$baseUrl/selected/rule', data: {'id': id});
  }

  Future<ProxyMode> getMode() async {
    final setting = await dio.get('$baseUrl/setting');
    if (setting.data.containsKey('mode') && setting.data['mode'] is String) {
      if (setting.data['mode'] == 'tun') {
        return ProxyMode.tun;
      }
      if (setting.data['mode'] == 'system') {
        return ProxyMode.system;
      }
    }
    return ProxyMode.mixed;
  }

  Future<void> exitCore() async {
    if (Platform.isWindows) {
      try {
        await dio.post('$baseUrl/manager/exit');
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
}

class ProxyItem {
  final String id;
  final String name;
  final String? server;
  final int? port;

  ProxyItem(this.id, this.name, this.server, this.port);

  ProxyItem.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as String),
        name = (json['name'] as String),
        server = (json['server'] as String),
        port = (json['port'] as int);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ProxyList {
  final List<ProxyItem> proxies;
  String selectedId;

  ProxyList(this.proxies, this.selectedId);

  ProxyList.fromJson(Map<String, dynamic> json)
      : proxies = json['proxies'] != null
            ? (json['proxies'] as List)
                .map((asset) =>
                    ProxyItem.fromJson(asset as Map<String, dynamic>))
                .toList()
            : <ProxyItem>[],
        selectedId = (json['selectedId'] as String);

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

enum ProxyMode { tun, system, mixed }
