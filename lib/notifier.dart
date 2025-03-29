import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      initializationSettings,
    );
  }

  Future<void> show(String body) async {
    NotificationDetails notificationDetails = NotificationDetails(
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'plainCategory',
        ),
        windows: WindowsNotificationDetails());

    await flutterLocalNotificationsPlugin
        .show(id++, _appName, body, notificationDetails, payload: "");
  }
}

final notifier = Notifier();
