import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lux/error.dart';
import 'package:lux/util/process_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../tr.dart';
import '../util/notifier.dart';
import 'core_config.dart';

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
  final dio = Dio();
  var needRestart = false;
  late String baseHttpUrl;
  late String baseWsUrl;
  WebSocketChannel? _trafficChannel;
  WebSocketChannel? _runtimeStatusChannel;
  WebSocketChannel? _eventChannel;

  CoreManager(
    this.baseUrl,
    this.coreProcess,
    this.token,
    this.onReady,
  ) {
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

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      // Received changes in available connectivity types!

      if (result.contains(ConnectivityResult.none)) {
        await Future.delayed(const Duration(seconds: 2));
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());
        if (!connectivityResult.contains(ConnectivityResult.none)) {
          return;
        }
        var isStarted = await getIsStarted();
        if (!isStarted) {
          return;
        }
        var setting = await getSetting();
        if (setting.mode == ProxyMode.tun || setting.mode == ProxyMode.mixed) {
          await stop();
          notifier.show(tr().noConnectionMsg);
          debugPrint("no connection, stop core");
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
        await Future.delayed(const Duration(milliseconds: 150));
        debugPrint("fail to connect to core, retry...");
      }
    }

    throw Exception('timeout');
  }

  Future<void> ping() async {
    try {
      await makeRequestUntilSuccess('$baseHttpUrl/ping');
    } catch (e) {
      throw CoreRunError("fail to ping core: ${e.toString()}");
    }
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

  Future<ProxyList> getProxyList() async {
    final proxiesRes = await dio.get('$baseHttpUrl/proxies');
    return ProxyList.fromJson(proxiesRes.data);
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

  Future<void> safeExit() async {
    try {
      await dio.post('$baseHttpUrl/manager/exit');
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
    await coreProcess?.run();
    await ping();
    onReady();
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

  Future<Setting> getSetting() async {
    final res = await dio.get('$baseHttpUrl/setting');
    if (!(res.data.containsKey('setting') &&
        res.data['setting'] is Map<String, dynamic>)) {
      throw Exception('invalid setting data');
    }
    return Setting.fromJson(res.data["setting"]);
  }

  Future<void> deleteProxies(List<String> ids) async {
    await dio.delete('$baseHttpUrl/proxies', data: {'ids': ids});
  }

  Future<SubscriptionList> getSubscriptionList() async {
    final res = await dio.get('$baseHttpUrl/subscription/all');
    return SubscriptionList.fromJson(res.data);
  }
}
