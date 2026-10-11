import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lux/const/const.dart';

class Notifier {
  final _appName = "Lux";
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var id = 0;

  Function(NotificationEvent event)? _handleEvent;

  Future<void> ensureInitialized() async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
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
    final windowsActions = <WindowsAction>[];

    final isNewReleaseMsg = payload == notifierPayloadNewRelease;

    if (isNewReleaseMsg) {
      windowsActions
          .add(WindowsAction(content: "Upgrade", arguments: upgradeActionId));
    }

    NotificationDetails notificationDetails = NotificationDetails(
      macOS: DarwinNotificationDetails(
        categoryIdentifier: 'plainCategory',
      ),
      windows: WindowsNotificationDetails(actions: windowsActions),
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
    var payload = notificationResponse.payload;
    var actionId = notificationResponse.actionId;
    NotificationEvent? event;

    if (payload == notifierPayloadNewRelease) {
      event = NotificationEvent.checkNewRelease;
    }

    if (notificationResponse.notificationResponseType ==
        NotificationResponseType.selectedNotificationAction) {
      if (actionId == upgradeActionId) {
        event = NotificationEvent.upgrade;
      }
    }

    debugPrint('notification payload: $payload, action id: $actionId');

    if (event == null) {
      return;
    }

    _handleEvent?.call(event);
  }

  void registerEventHandler(Function(NotificationEvent event) eventHandler) {
    _handleEvent = eventHandler;
  }
}

const notifierPayloadNewRelease = "new_release";
const upgradeActionId = "upgrade_action_id";

enum NotificationEvent {
  checkNewRelease,
  upgrade,
}

final notifier = Notifier();
