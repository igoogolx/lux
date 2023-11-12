import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:lux/notifier.dart';
import 'package:lux/process_manager.dart';


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
  final ProcessManager? coreProcess;
  final String baseUrl;
  final FlutterDesktopSleep flutterDesktopSleep = FlutterDesktopSleep();
  final dio = Dio();
  var needRestart= false;

  Future<void> powerMonitorHandler(String? s) async {
    if (s != null) {
      if (s == 'sleep') {
        final managerRes = await dio.get('$baseUrl/manager');
        var isStarted = managerRes.data['isStarted'];
        if(isStarted){
          final settingRes = await dio.get('$baseUrl/setting');
          var mode = settingRes.data['setting']['mode'];
          if (mode=="tun") {
            needRestart=true;
            await dio.post('$baseUrl/manager/stop');
          }
        }
      } else if (s == 'woke_up') {
        if (needRestart) {
          needRestart = false;
          await Future.delayed(const Duration(seconds: 2));
          await dio.post('$baseUrl/manager/start');
          notifier.show("Reconnected");
        }
      } else if (s == 'terminate_app') {
        coreProcess?.exit();
        exit(0);
      }
    }
  }

  CoreManager(this.baseUrl, this.coreProcess) {
    dio.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;
    dio.options.receiveTimeout = const Duration(seconds: 1);
    if(Platform.isMacOS){
      flutterDesktopSleep.setWindowSleepHandler(powerMonitorHandler);
    }
    if(Platform.isWindows){
      FlutterWindowClose.setWindowShouldCloseHandler(powerMonitorHandler);
    }
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
          makeRequestUntilSuccess(url);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    throw Exception('timeout');
  }

  Future<void> ping() async {
    await makeRequestUntilSuccess('$baseUrl/ping');
  }

  Future<void> restart() async {
    coreProcess?.exit();
    await coreProcess?.run();
  }
}
