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
          if (mode == "tun") {
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

  CoreManager(
      this.baseUrl, this.coreProcess, this.token, this.onReady,  this.onOsSleep) {
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

    while (stopwatch.elapsedMilliseconds < 3000) {
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
