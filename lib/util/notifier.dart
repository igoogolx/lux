import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lux/const/const.dart';
import 'package:url_launcher/url_launcher.dart';

class Notifier {
  final _appName = "Lux";
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var id = 0;

  Future<void> ensureInitialized() async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      iconPath: Paths.appIcon,
      appName: _appName,
      appUserModelId: 'com.igoogolx.lux',
      //keep guid the same as inno setup
      guid: '80DF132E-434A-4DAB-9BC8-48A79C8383B9',
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );
    await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  Future<void> show(String body, [String? payload]) async {
    NotificationDetails notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        categoryIdentifier: 'plainCategory',
      ),
      windows: WindowsNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
        id: id++,
        title: Platform.isMacOS ? _appName : "",
        body: body,
        notificationDetails: notificationDetails,
        payload: payload);
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      if (notificationResponse.payload == notifierPayloadNewRelease) {
        launchUrl(Uri.parse(latestReleaseUrl));
      }
      debugPrint('notification payload: $payload');
    }
  }
}

const notifierPayloadNewRelease = "new_release";

final notifier = Notifier();
