import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:lux/process_manager.dart';

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
  var lastIsStarted = false;

  CoreManager(this.baseUrl, this.coreProcess) {
    dio.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;
    dio.options.receiveTimeout = const Duration(seconds: 1);
    flutterDesktopSleep.setWindowSleepHandler((String? s) async {
      if (s != null) {
        if (s == 'sleep') {
          final response = await dio.get('$baseUrl/manager');
          lastIsStarted = response.data['isStarted'];
          if (lastIsStarted) {
            await dio.post('$baseUrl/manager/stop');
          }
        } else if (s == 'woke_up') {
          if (lastIsStarted) {
            await dio.post('$baseUrl/manager/start');
            lastIsStarted = false;
            LocalNotification notification = LocalNotification(
              title: "Lux",
              body: "Reconnected",
            );
            notification.show();
          }
        } else if (s == 'terminate_app') {
          coreProcess?.exit();
          exit(0);
        }
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
}
