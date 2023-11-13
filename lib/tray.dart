import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:system_tray/system_tray.dart';

Future<void> initSystemTray(void Function() openDashboard, exitApp) async {
  String path = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray.icns';

  final SystemTray systemTray = SystemTray();

  // We first init the systray menu
  await systemTray.initSystemTray(
    iconPath: path,
    isTemplate: true
  );
  systemTray.setToolTip("Lux");

  // create context menu
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(label: 'Lux', enabled: false),
    MenuItemLabel(label: 'Dashboard', onClicked: (menuItem) => openDashboard()),
    MenuItemLabel(label: 'Exit', onClicked: (menuItem) => exitApp()),
  ]);

  // set context menu
  await systemTray.setContextMenu(menu);

  // handle system tray event
  systemTray.registerSystemTrayEventHandler((eventName) {
    debugPrint("eventName: $eventName");
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? openDashboard() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : openDashboard();
    }
  });
}
